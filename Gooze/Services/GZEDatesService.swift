//
//  GZEDatesService.swift
//  Gooze
//
//  Created by Yussel on 3/27/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Gloss
import SocketIO
import ReactiveSwift
import Alamofire
import enum Result.NoError

class GZEDatesService: NSObject {

    static let shared = GZEDatesService()

    let dateRequestRepository: GZEDateRequestRepositoryProtocol = GZEDateRequestApiRepository()
    let userRepository: GZEUserRepositoryProtocol = GZEUserApiRepository()

    let bgSessionManager: SessionManager

    let lastReceivedRequest = MutableProperty<GZEDateRequest?>(nil)
    let receivedRequests = MutableProperty<[GZEDateRequest]>([])
    
    let lastSentRequest = MutableProperty<GZEDateRequest?>(nil)
    let sentRequests = MutableProperty<[GZEDateRequest]>([])

    var activeRequest: MutableProperty<GZEDateRequest>?

    let userLastLocation = MutableProperty<GZEUser?>(nil)
    var sendLocationDisposable: Disposable?
    var socketEventsDisposable: Disposable?

    var dateSocket: DatesSocket? {
        return GZESocketManager.shared[DatesSocket.namespace] as? DatesSocket
    }

    override init() {
        let configuration = URLSessionConfiguration.background(withIdentifier: "net.gooze.app.background")
        self.bgSessionManager = Alamofire.SessionManager(configuration: configuration)

        super.init()
        receivedRequests.signal.observeValues {
            log.debug("receivedRequests changed: \(String(describing: $0.toJSONArray()))")
        }
        sentRequests.signal.observeValues {
            log.debug("sentRequests changed: \(String(describing: $0.toJSONArray()))")
        }
    }
    
    func findUnrespondedRequests() -> SignalProducer<[GZEDateRequest], GZEError> {
        return self.dateRequestRepository.findUnresponded()
    }

    func find(byId id: String) -> SignalProducer<GZEDateRequest, GZEError> {
        guard let dateSocket = self.dateSocket else {
            log.error("Date socket not found")
            return SignalProducer(error: .datesSocket(error: DatesSocketError.unexpected))
        }

        log.debug("finding date request... [id=\(id)]")
        return SignalProducer { sink, disposable in

            disposable.add {
                log.debug("find request signal disposed")
            }

            dateSocket.emitWithAck(.findRequestById, id).timingOut(after: GZESocket.ackTimeout) {[weak self] data in
                if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                    log.error("No ack received from server")
                    sink.send(error: .datesSocket(error: .noAck))
                    return
                }

                if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {

                    log.error("\(String(describing: error.toJSON()))")
                    sink.send(error: .datesSocket(error: .unexpected))

                } else if let dateRequestJson = data[1] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) {

                    self?.upsert(dateRequest: dateRequest)
                    sink.send(value: dateRequest)

                } else {
                    log.error("Unable to parse data to expected objects")
                    sink.send(error: .datesSocket(error: .unexpected))
                }
            }
        }
    }

    func requestDate(to recipientId: String) -> SignalProducer<GZEDateRequest, GZEError> {
        guard let dateSocket = self.dateSocket else {
            log.error("Date socket not found")
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }

        log.debug("sending date request...")
        return SignalProducer { sink, disposable in
            dateSocket.emitWithAck(.dateRequestSent, recipientId).timingOut(after: GZESocket.ackTimeout) {[weak self] data in
                log.debug("ack data: \(data)")
                
                disposable.add {
                    log.debug("acceptDateRequest signal disposed")
                }
                
                if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                    log.error("No ack received from server")
                    sink.send(error: .datesSocket(error: .noAck))
                    return
                }
                
                if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {

                    self?.handleError(error, sink)
                    
                } else if let dateRequestJson = data[1] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) {
                    
                    log.debug("Date request successfully sent")
                    self?.sentRequests.value.upsert(dateRequest){$0 == dateRequest}
                    self?.lastSentRequest.value = dateRequest
                    sink.send(value: dateRequest)
                    sink.sendCompleted()
                } else {
                    log.error("Unable to parse data to expected objects")
                    sink.send(error: .datesSocket(error: .unexpected))
                }
            }
        }
    }
    
    func acceptDateRequest(withId requestId: String?) -> SignalProducer<GZEDateRequest, GZEError> {
        guard let dateSocket = self.dateSocket else {
            log.error("Date socket not found")
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }
        
        guard let requestId = requestId else {
            log.error("Request id is required to accept a request")
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }
        
        return SignalProducer { sink, disposable in
            log.debug("emitting accept request...")
            dateSocket.emitWithAck(.acceptRequest, requestId).timingOut(after: GZESocket.ackTimeout) {[weak self] data in
                log.debug("ack data: \(data)")
                
                disposable.add {
                    log.debug("acceptDateRequest signal disposed")
                }
                
                if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                    log.error("No ack received from server")
                    sink.send(error: .datesSocket(error: .noAck))
                    return
                }
                
                if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {
                    
                   self?.handleError(error, sink)
                    
                } else if let dateRequestJson = data[1] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) {
                    
                    log.debug("Date request successfully accepted")
                    GZEDatesService.shared.receivedRequests.value.upsert(dateRequest) {$0 == dateRequest}
                    GZEDatesService.shared.lastReceivedRequest.value = dateRequest
                    sink.send(value: dateRequest)
                    sink.sendCompleted()
                    
                } else {
                    log.error("Unable to parse data to expected objects")
                    sink.send(error: .datesSocket(error: .unexpected))
                }
            }
        }
    }

    func createCharge(
        dateRequest: GZEDateRequest,
        amount: Decimal,
        clientTaxAmount: Decimal,
        goozeTaxAmount: Decimal,
        paymentMethodToken: String? = nil,
        paymentMethodNonce: String? = nil,
        senderId: String,
        username: String,
        chat: GZEChat,
        mode: GZEChatViewMode
    ) -> SignalProducer<(GZEDateRequest, GZEUser), GZEError> {

        return dateRequestRepository.createCharge(
            dateRequest: dateRequest,
            amount: amount,
            clientTaxAmount: clientTaxAmount,
            goozeTaxAmount: goozeTaxAmount,
            paymentMethodToken: paymentMethodToken,
            paymentMethodNonce: paymentMethodNonce,
            senderId: senderId,
            username: username,
            chat: chat,
            mode: mode
        )
    }

    func createCharge(requestId: String, senderId: String, username: String, chat: GZEChat, mode: GZEChatViewMode) -> SignalProducer<GZEDateRequest, GZEError> {
        guard let dateSocket = self.dateSocket else {
            log.error("Date socket not found")
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }

        guard let chatJson = chat.toJSON() else {
            log.error("Failed to parse GZEChat to JSON")
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }

        guard let messageJson = GZEChatMessage(text: "service.dates.dateCreated", senderId: senderId, chatId: chat.id, type: .info).toJSON() else {
            log.error("Failed to parse GZEChatMessage to JSON")
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }

        return SignalProducer { sink, disposable in
            log.debug("emitting create date event...")
            dateSocket.emitWithAck(.createCharge, requestId, messageJson, username, chatJson, mode.rawValue).timingOut(after: GZESocket.ackTimeout) {data in
                log.debug("ack data: \(data)")

                disposable.add {
                    log.debug("acceptDateRequest signal disposed")
                }

                if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                    log.error("No ack received from server")
                    sink.send(error: .datesSocket(error: .noAck))
                    return
                }

                if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {

                    log.error("\(String(describing: error.toJSON()))")
                    sink.send(error: .datesSocket(error: .unexpected))

                } else if
                    let dateRequestJson = data[1] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson),
                    let userJson = data[2] as? JSON, let user = GZEUser(json: userJson)
                {
                    if user.id == GZEAuthService.shared.authUser?.id {
                        GZEAuthService.shared.authUser = user
                    } else {
                        log.error("Missmatch user received")
                    }

                    log.debug("Date successfully created")
                    GZEDatesService.shared.upsert(dateRequest: dateRequest)
                    GZEDatesService.shared.sendLocationUpdate(to: dateRequest.recipient.id, dateRequest: dateRequest)
                    sink.send(value: dateRequest)
                    sink.sendCompleted()

                } else {
                    log.error("Unable to parse data to expected objects")
                    sink.send(error: .datesSocket(error: .unexpected))
                }
            }
        }
    }

    func startDate(_ dateRequest: GZEDateRequest) -> SignalProducer<GZEDateRequest, GZEError> {
        return self.dateRequestRepository.startDate(dateRequest)
            .map{
                let (dateRequest, user) = $0

                if user.id == GZEAuthService.shared.authUser?.id {
                    GZEAuthService.shared.authUser = user
                } else {
                    log.error("Missmatch user received")
                }

                return dateRequest
            }
    }

    func endDate(_ dateRequest: GZEDateRequest) -> SignalProducer<GZEDateRequest, GZEError> {
        return self.dateRequestRepository.endDate(dateRequest)
            .map{
                let (dateRequest, user) = $0

                if user.id == GZEAuthService.shared.authUser?.id {
                    GZEAuthService.shared.authUser = user
                } else {
                    log.error("Missmatch user received")
                }

                return dateRequest
            }
    }

    func cancelDate(_ dateRequest: GZEDateRequest) -> SignalProducer<GZEDateRequest, GZEError> {
        return self.dateRequestRepository.cancelDate(dateRequest)
            .map{
                let (dateRequest, user) = $0

                if user.id == GZEAuthService.shared.authUser?.id {
                    GZEAuthService.shared.authUser = user
                } else {
                    log.error("Missmatch user received")
                }

                return dateRequest
        }
    }

    func sendLocationUpdate(to recipientId: String, dateRequest: GZEDateRequest) {
        guard let authUser = GZEAuthService.shared.authUser else {return}

        let user = GZEUser(
            id: authUser.id,
            username: authUser.username,
            email: authUser.email
        )

        sendLocationDisposable?.dispose()

        GZELocationService.shared.startUpdatingLocation(background: true)

        sendLocationDisposable = GZELocationService.shared.lastLocation.producer.skipNil().throttle(1.0, on: QueueScheduler.main)
            .flatMap(.latest){[weak self] location -> SignalProducer<Bool, GZEError> in
                user.currentLocation = GZEUser.GeoPoint(CLCoord: location.coordinate)
                guard let this = self else {return SignalProducer.empty}

                let isArriving = location.distance(from: dateRequest.location.toCLLocation()) < 100

                if UIApplication.shared.applicationState == .background {
                    return this.sendLocationUpdateInBackground(to: recipientId, user: user, isArriving: isArriving, dateRequestId: dateRequest.id).throttle(10.0, on: QueueScheduler.main).flatMapError{ error in
                        log.error(error.localizedDescription)
                        return SignalProducer.empty
                    }
                } else {
                    return this.sendLocationUpdateInForeground(to: recipientId, user: user, isArriving: isArriving, dateRequestId: dateRequest.id).flatMapError{ error in
                        log.error(error.localizedDescription)
                        return SignalProducer.empty
                    }
                }
            }
            .take(during: self.reactive.lifetime)
            .start { event in
                log.debug("send location event received: \(event)")
            }
    }

    func stopSendingLocationUpdates() {
        GZELocationService.shared.stopUpdatingLocation()
        self.sendLocationDisposable?.dispose()
    }

    func sendLocationUpdateInForeground(to recipientId: String, user: GZEUser, isArriving: Bool, dateRequestId: String) -> SignalProducer<Bool, GZEError> {
        log.debug("sendLocationUpdateInForeground")
        guard let dateSocket = self.dateSocket else {
            log.error("Date socket not found")
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }

        guard let userJson = user.toJSON() else {
            log.error("Failed to parse GZEUser to JSON")
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }

        return SignalProducer { sink, disposable in
            log.debug("emitting updateLocation...")
            dateSocket.emitWithAck(.updateLocation, recipientId, userJson, isArriving, dateRequestId).timingOut(after: GZESocket.ackTimeout) {data in
                log.debug("ack data: \(data)")

                disposable.add {
                    log.debug("sendLocationUpdateInForeground signal disposed")
                }

                if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                    log.error("No ack received from server")
                    sink.send(error: .datesSocket(error: .noAck))
                    return
                }

                if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {

                    log.error("\(String(describing: error.toJSON()))")
                    sink.send(error: .datesSocket(error: .unexpected))

                } else {
                    log.debug("Location successfully updated")
                    sink.sendCompleted()
                }
            }
        }
    }

    func sendLocationUpdateInBackground(to recipientId: String, user: GZEUser, isArriving: Bool, dateRequestId: String) -> SignalProducer<Bool, GZEError> {
        log.debug("sendLocationUpdateInBackground")
        guard let userJson = user.toJSON() else {
            log.error("Failed to parse GZEUser to JSON")
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }

        return SignalProducer {[weak self] sink, disposable in
            disposable.add {
                log.debug("sendLocationUpdateInBackground signal disposed")
            }

            guard let this = self else {
                log.error("self was disposed")
                sink.send(error: .datesSocket(error: .unexpected))
                return
            }

            let params: [String: Any] = ["location": [
                "recipientId": recipientId,
                "user": userJson,
                "isArriving": isArriving,
                "dateRequestId": dateRequestId
            ]]

            this.bgSessionManager.request(GZEUserRouter.sendLocationUpdate(parameters: params))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: { (json: JSON) in
                    return true
                }))
        }
    }
    
    func upsert(dateRequest: GZEDateRequest) {
        guard let authUser = GZEAuthService.shared.authUser else {
            log.error("auth user not found")
            return
        }
        
        if dateRequest.sender.id == authUser.id {
            self.sentRequests.value.upsert(dateRequest){$0 == dateRequest}
            self.lastSentRequest.value = dateRequest
        } else if dateRequest.recipient.id == authUser.id {
            self.receivedRequests.value.upsert(dateRequest) {$0 == dateRequest}
            self.lastReceivedRequest.value = dateRequest
        }
    }

    func listenSocketEvents() {
        self.socketEventsDisposable?.dispose()
        self.socketEventsDisposable = self.dateSocket?.socketEventsEmitter
            .signal
            .skipNil()
            .filter{$0 == .authenticated}
            .flatMap(.latest) { _ -> SignalProducer<GZEUser, NoError> in
                return GZEAuthService.shared.loadAuthUser()
                    .flatMapError{ error in
                        log.error(error)
                        GZEDatesService.shared.stopSendingLocationUpdates()
                        return SignalProducer.empty
                    }
            }
            .flatMap(.latest) { user -> SignalProducer<(GZEUser.Mode, GZEDateRequest?), NoError> in
                guard let mode = user.mode, user.status == .onDate else {
                    GZEDatesService.shared.stopSendingLocationUpdates()
                    return SignalProducer.empty
                }

                let findBy: String
                if mode == .gooze {
                    findBy = "recipientId"
                } else {
                    findBy = "senderId"
                }

                return GZEDatesService.shared.dateRequestRepository.findActiveDate(by: findBy)
                    .map{(mode, $0.first)}
                    .flatMapError{ error in
                        log.error(error)
                        GZEDatesService.shared.stopSendingLocationUpdates()
                        return SignalProducer.empty
                }
            }
            .observeValues { (mode, dateRequest) in
                guard
                    let dateRequest = dateRequest,
                    let date = dateRequest.date,
                    date.status == .route ||
                    date.status == .starting && (mode == .gooze && !date.recipientStarted || mode == .client && !date.senderStarted)

                else {
                    GZEDatesService.shared.stopSendingLocationUpdates()
                    return
                }

                if mode == .gooze {
                    GZEDatesService.shared.sendLocationUpdate(to: dateRequest.sender.id, dateRequest: dateRequest)
                } else {
                    GZEDatesService.shared.sendLocationUpdate(to: dateRequest.recipient.id, dateRequest: dateRequest)
                }
            }
    }

    func handleError(_ error: GZEApiError, _ sink: Observer<GZEDateRequest, GZEError>) {

        guard let errorCode = error.code else {
            log.error("\(String(describing: error.toJSON()))")
            sink.send(error: .datesSocket(error: .unexpected))
            return
        }

        if let datesError = DatesSocketError(rawValue: errorCode) {
            log.debug("Error: \(datesError)")
            sink.send(error: .datesSocket(error: datesError))
            return
        }

        if errorCode == GZEApiError.Code.userIncompleteProfile.rawValue {
            log.error("\(String(describing: error.toJSON()))")
            sink.send(error: .repository(error: .GZEApiError(error: error)))
            return
        }

        log.error("\(String(describing: error.toJSON()))")
        sink.send(error: .datesSocket(error: .unexpected))
        return
    }

    func cleanup() {
        self.socketEventsDisposable?.dispose()
        self.stopSendingLocationUpdates()
        self.sentRequests.value = []
        self.receivedRequests.value = []
    }

    // MARK: deinit
    deinit {
        log.debug("\(self) disposed")
    }
}
