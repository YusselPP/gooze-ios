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

    let userLastLocation = MutableProperty<GZEUser?>(nil)
    var sendLocationDisposable: Disposable?
    var socketEventsDisposable: Disposable?

    var dateSocket: DatesSocket? {
        return GZESocketManager.shared[DatesSocket.namespace] as? DatesSocket
    }
    
    var message = MutableProperty<String?>(nil)
    
    var errorMessage = MutableProperty<String?>(nil)

    override init() {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.gooze.app.background")
        self.bgSessionManager = Alamofire.SessionManager(configuration: configuration)

        super.init()
        receivedRequests.signal.observeValues {
            log.debug("receivedRequests changed: \(String(describing: $0.toJSONArray()))")
        }
        sentRequests.signal.observeValues {
            log.debug("sentRequests changed: \(String(describing: $0.toJSONArray()))")
        }
    }
    
    func findUnrespondedRequests() {
        GZEDateRequestApiRepository().findUnresponded().startWithSignal{[weak self] sink, disposable in
            sink.observe { event in
                log.debug("event received: \(event)")
                switch event {
                case .value(let dateRequests):
                    self?.receivedRequests.value = dateRequests
                default: break
                }
            }
        }
    }

    func find(byId id: String) -> SignalProducer<GZEDateRequest, GZEError> {
        guard let dateSocket = self.dateSocket else {
            log.error("Date socket not found")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
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
                    self?.errorMessage.value = DatesSocketError.noAck.localizedDescription
                    sink.send(error: .datesSocket(error: .noAck))
                    return
                }

                if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {

                    log.error("\(String(describing: error.toJSON()))")
                    self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
                    sink.send(error: .datesSocket(error: .unexpected))

                } else if let dateRequestJson = data[1] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) {

                    self?.upsert(dateRequest: dateRequest)
                    sink.send(value: dateRequest)

                } else {
                    log.error("Unable to parse data to expected objects")
                    self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
                    sink.send(error: .datesSocket(error: .unexpected))
                }
            }
        }
    }

    func requestDate(to recipientId: String) -> SignalProducer<GZEDateRequest, GZEError> {
        guard let dateSocket = self.dateSocket else {
            log.error("Date socket not found")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
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
                    self?.errorMessage.value = DatesSocketError.noAck.localizedDescription
                    sink.send(error: .datesSocket(error: .noAck))
                    return
                }
                
                if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {
                    
                    if error.code == DatesSocketError.requestAlreadySent.rawValue {
                        log.debug("Request already sent")
                        self?.errorMessage.value = DatesSocketError.requestAlreadySent.localizedDescription
                        sink.send(error: .datesSocket(error: .requestAlreadySent))
                    } else {
                        log.error("\(String(describing: error.toJSON()))")
                        self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
                        sink.send(error: .datesSocket(error: .unexpected))
                    }
                    
                } else if let dateRequestJson = data[1] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) {
                    
                    log.debug("Date request successfully sent")
                    self?.sentRequests.value.upsert(dateRequest){$0 == dateRequest}
                    self?.lastSentRequest.value = dateRequest
                    self?.message.value = "service.dates.requestSuccessfullySent".localized()
                    sink.send(value: dateRequest)
                    sink.sendCompleted()
                } else {
                    log.error("Unable to parse data to expected objects")
                    self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
                    sink.send(error: .datesSocket(error: .unexpected))
                }
            }
        }
    }
    
    func acceptDateRequest(withId requestId: String?) -> SignalProducer<GZEDateRequest, GZEError> {
        guard let dateSocket = self.dateSocket else {
            log.error("Date socket not found")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }
        
        guard let requestId = requestId else {
            log.error("Request id is required to accept a request")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
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
                    self?.errorMessage.value = DatesSocketError.noAck.localizedDescription
                    sink.send(error: .datesSocket(error: .noAck))
                    return
                }
                
                if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {
                    
                    if error.code == DatesSocketError.invalidSatus.rawValue {
                        log.debug("Request invalid status")
                        self?.errorMessage.value = DatesSocketError.invalidSatus.localizedDescription
                        sink.send(error: .datesSocket(error: .invalidSatus))
                    } else {
                        log.error("\(String(describing: error.toJSON()))")
                        self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
                        sink.send(error: .datesSocket(error: .unexpected))
                    }
                    
                } else if let dateRequestJson = data[1] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) {
                    
                    log.debug("Date request successfully accepted")
                    GZEDatesService.shared.receivedRequests.value.upsert(dateRequest) {$0 == dateRequest}
                    GZEDatesService.shared.lastReceivedRequest.value = dateRequest
                    sink.send(value: dateRequest)
                    sink.sendCompleted()
                    
                } else {
                    log.error("Unable to parse data to expected objects")
                    self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
                    sink.send(error: .datesSocket(error: .unexpected))
                }
            }
        }
    }

    func createCharge(requestId: String, senderId: String, username: String, chat: GZEChat, mode: GZEChatViewMode) -> SignalProducer<Void, GZEError> {
        guard let dateSocket = self.dateSocket else {
            log.error("Date socket not found")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }

        guard let chatJson = chat.toJSON() else {
            log.error("Failed to parse GZEChat to JSON")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }

        guard let messageJson = GZEChatMessage(text: "service.dates.dateCreated", senderId: senderId, chatId: chat.id, type: .info).toJSON() else {
            log.error("Failed to parse GZEChatMessage to JSON")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }

        return SignalProducer { sink, disposable in
            log.debug("emitting create date event...")
            dateSocket.emitWithAck(.createCharge, requestId, messageJson, username, chatJson, mode.rawValue).timingOut(after: GZESocket.ackTimeout) {[weak self] data in
                log.debug("ack data: \(data)")

                disposable.add {
                    log.debug("acceptDateRequest signal disposed")
                }

                if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                    log.error("No ack received from server")
                    self?.errorMessage.value = DatesSocketError.noAck.localizedDescription
                    sink.send(error: .datesSocket(error: .noAck))
                    return
                }

                if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {

                    log.error("\(String(describing: error.toJSON()))")
                    self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
                    sink.send(error: .datesSocket(error: .unexpected))

                } else if let dateRequestJson = data[1] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) {

                    log.debug("Date successfully created")
                    GZEDatesService.shared.upsert(dateRequest: dateRequest)
                    GZEDatesService.shared.sendLocationUpdate(to: dateRequest.recipient.id)
                    sink.sendCompleted()

                } else {
                    log.error("Unable to parse data to expected objects")
                    self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
                    sink.send(error: .datesSocket(error: .unexpected))
                }
            }
        }
    }

    func startDate(_ dateRequest: GZEDateRequest) -> SignalProducer<GZEDateRequest, GZEError> {
        return self.dateRequestRepository.startDate(dateRequest)
    }

    func endDate(_ dateRequest: GZEDateRequest) -> SignalProducer<GZEDateRequest, GZEError> {
        return self.dateRequestRepository.endDate(dateRequest)
    }

    func sendLocationUpdate(to recipientId: String) {
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

                if UIApplication.shared.applicationState == .background {
                    return this.sendLocationUpdateInBackground(to: recipientId, user: user).throttle(10.0, on: QueueScheduler.main).flatMapError{ error in
                        log.error(error.localizedDescription)
                        return SignalProducer.empty
                    }
                } else {
                    return this.sendLocationUpdateInForeground(to: recipientId, user: user).flatMapError{ error in
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

    func sendLocationUpdateInForeground(to recipientId: String, user: GZEUser) -> SignalProducer<Bool, GZEError> {
        log.debug("sendLocationUpdateInForeground")
        guard let dateSocket = self.dateSocket else {
            log.error("Date socket not found")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }

        guard let userJson = user.toJSON() else {
            log.error("Failed to parse GZEUser to JSON")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }

        return SignalProducer { sink, disposable in
            log.debug("emitting updateLocation...")
            dateSocket.emitWithAck(.updateLocation, recipientId, userJson).timingOut(after: GZESocket.ackTimeout) {[weak self] data in
                log.debug("ack data: \(data)")

                disposable.add {
                    log.debug("sendLocationUpdateInForeground signal disposed")
                }

                if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                    log.error("No ack received from server")
                    self?.errorMessage.value = DatesSocketError.noAck.localizedDescription
                    sink.send(error: .datesSocket(error: .noAck))
                    return
                }

                if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {

                    log.error("\(String(describing: error.toJSON()))")
                    self?.errorMessage.value = DatesSocketError.unexpected.localizedDescription
                    sink.send(error: .datesSocket(error: .unexpected))

                } else {
                    log.debug("Location successfully updated")
                    sink.sendCompleted()
                }
            }
        }
    }

    func sendLocationUpdateInBackground(to recipientId: String, user: GZEUser) -> SignalProducer<Bool, GZEError> {
        log.debug("sendLocationUpdateInBackground")
        guard let userJson = user.toJSON() else {
            log.error("Failed to parse GZEUser to JSON")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
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
                "user": userJson
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
                guard let dateRequest = dateRequest, dateRequest.date?.status == .route else {
                    GZEDatesService.shared.stopSendingLocationUpdates()
                    return
                }

                if mode == .gooze {
                    GZEDatesService.shared.sendLocationUpdate(to: dateRequest.sender.id)
                } else {
                    GZEDatesService.shared.sendLocationUpdate(to: dateRequest.recipient.id)
                }
            }
    }
}
