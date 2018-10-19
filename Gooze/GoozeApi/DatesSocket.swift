 //
//  DatesSocket.swift
//  Gooze
//
//  Created by Yussel on 3/19/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import SocketIO
import Gloss
import ReactiveSwift

class DatesSocket: GZESocket {
    enum DateEvent: String {
        case findRequestById
        
        case dateRequestSent
        case dateRequestReceived
        case dateRequestReceivedAck
        
        case acceptRequest
        case requestAccepted

        case createCharge
        case createChargeSuccess

        case updateLocation
        case locationUpdateReceived
        
        case dateStarted
        case dateEnded
        case dateStatusChanged
    }

    static let namespace = "/dates"

    // MARK - init
    override init(socketURL: URL, config: SocketIOClientConfiguration) {
        super.init(socketURL: socketURL, config: config)
        log.debug("\(self) init")
        self.addEventHandlers()
    }

    private func addEventHandlers() {
        log.debug("adding dates socket handlers")
        self.on(.dateRequestReceived) {data, ack in
            guard let dateRequestJson = data[0] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) else {
                log.error("Unable to parse data[0], expected data[0] to be a dateRequest, found: \(data[0])")
                return
            }
            log.debug("Date request received: \(String(describing: dateRequest.toJSON()))")


            GZEDatesService.shared.receivedRequests.value.upsert(dateRequest) {$0 == dateRequest}
            GZEDatesService.shared.lastReceivedRequest.value = dateRequest

            ack.with()
        }
        
        self.on(.dateRequestReceivedAck) {data, ack in
            guard let dateRequestJson = data[0] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) else {
                log.error("Unable to parse data[0], expected data[0] to be a dateRequest, found: \(data[0])")
                return
            }
            log.debug("Date request received ack: \(String(describing: dateRequest.toJSON()))")

            GZEDatesService.shared.sentRequests.value.upsert(dateRequest) {$0 == dateRequest}
            GZEDatesService.shared.lastSentRequest.value = dateRequest
            
            ack.with()
        }
        
        self.on(.requestAccepted) { data, ack in
            guard let dateRequestJson = data[0] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) else {
                log.error("Unable to parse data[0], expected data[0] to be a dateRequest, found: \(data[0])")
                return
            }
            log.debug("Accepted date request: \(String(describing: dateRequest.toJSON()))")
            
            
            GZEDatesService.shared.sentRequests.value.upsert(dateRequest) {$0 == dateRequest}
            GZEDatesService.shared.lastSentRequest.value = dateRequest

            let recipient = dateRequest.recipient
            let message = String(format: "service.dates.requestAccepted".localized(), recipient.username)
            GZEAlertService.shared.showTopAlert(text: message) {[weak self] in
                guard let chat = dateRequest.chat else {
                    log.error("Unable to open the chat, found nil chat on date request")
                    self?.handleError(.message(text: "service.chat.invalidChatId", args: []))
                    return
                }
                var dateRequestProperty: MutableProperty<GZEDateRequest>
                if let activeRequest = GZEDatesService.shared.activeRequest {
                    dateRequestProperty = activeRequest
                } else {
                    dateRequestProperty = MutableProperty(dateRequest)
                }

                GZEChatService.shared.openChat(viewModel: GZEChatViewModelDates(chat: chat, dateRequest: dateRequestProperty, mode: .client, username: recipient.username))
            }
            
            ack.with()
        }

        self.on(.createChargeSuccess) { data, ack in
            guard let dateRequestJson = data[0] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) else {
                log.error("Unable to parse data[0], expected data[0] to be a dateRequest, found: \(data[0])")
                return
            }

            guard let userJson = data[1] as? JSON, let user = GZEUser(json: userJson) else {
                log.error("Unable to parse data[1], expected data[1] to be a GZEUser, found: \(data[1])")
                return
            }

            log.debug("Charge success on date request [id=\(dateRequest.id)]")

            // TODO: Test updated authUser
            if user.id == GZEAuthService.shared.authUser?.id {
                GZEAuthService.shared.authUser = user
            } else {
                log.error("Missmatch user received")
            }
            GZEDatesService.shared.upsert(dateRequest: dateRequest)
            GZEDatesService.shared.sendLocationUpdate(to: dateRequest.sender.id, dateRequest: dateRequest)

            ack.with()
        }

        self.on(.locationUpdateReceived) { data, ack in
            guard let userJson = data[0] as? JSON, let user = GZEUser(json: userJson) else {
                log.error("Unable to parse data[0], expected data[0] to be a GZEUser, found: \(data[0])")
                return
            }
            log.debug("locationUpdateReceived [user=\(String(describing: user.toJSON()))]")

            GZEDatesService.shared.userLastLocation.value = user

            ack.with()
        }

        self.on(.dateStatusChanged) { data, ack in
            guard let dateRequestJson = data[0] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) else {
                log.error("Unable to parse data[0], expected data[0] to be a dateRequest, found: \(data[0])")
                return
            }
            log.debug("Date request [id=\(dateRequest.id)] changed its status")

            GZEDatesService.shared.upsert(dateRequest: dateRequest)

            if let date = dateRequest.date, date.status == .progress || date.status == .canceled {
                GZEDatesService.shared.stopSendingLocationUpdates()
            }

            let authUserId = GZEAuthService.shared.authUser?.id
            var username = ""

            if dateRequest.status == .rejected {
                if dateRequest.sender.id == authUserId {
                    username = dateRequest.recipient.username
                    GZEAlertService.shared.showTopAlert(text: String(format: "service.dates.becameUnavailable".localized(), username))
                }
            }

            // Update authUser if its included on data
            if let userJson = data[1] as? JSON, let user = GZEUser(json: userJson) {
                log.debug("Updating authUser[id=\(String(describing: authUserId))] with user found at data[1] \(data[1])")

                if user.id == authUserId {
                    GZEAuthService.shared.authUser = user
                } else {
                    log.error("Missmatch user received")
                }
            }


            ack.with()
        }
    }

    func handleError(_ error: GZEError) {
        GZEAlertService.shared.showBottomAlert(text: error.localizedDescription)
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}

extension SocketIOClient {

    func emit(_ clientEvent: DatesSocket.DateEvent, _ items: SocketData...) {

        emit(clientEvent.rawValue, items)
    }

    func emitWithAck(_ clientEvent: DatesSocket.DateEvent, _ items: SocketData...) -> OnAckCallback {

        return emitWithAck(clientEvent.rawValue, items)
    }

    @discardableResult
    func on(_ clientEvent: DatesSocket.DateEvent, callback: @escaping NormalCallback) -> UUID {

        return on(clientEvent.rawValue, callback: callback)
    }

}
