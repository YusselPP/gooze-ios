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
        
        self.on(.requestAccepted) {[weak self] data, ack in
            guard let dateRequestJson = data[0] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) else {
                log.error("Unable to parse data[0], expected data[0] to be a dateRequest, found: \(data[0])")
                return
            }
            log.debug("Accepted date request: \(String(describing: dateRequest.toJSON()))")
            
            
            GZEDatesService.shared.sentRequests.value.upsert(dateRequest) {$0 == dateRequest}
            GZEDatesService.shared.lastSentRequest.value = dateRequest

            let recipient = dateRequest.recipient
            if let topVC = self?.topViewController {
                let message = String(format: "service.dates.requestAccepted".localized(), recipient.username)
                GZEAlertService.shared.showTopAlert(text: message) {
                    guard let chat = dateRequest.chat else {
                        log.error("Unable to open the chat, found nil chat on date request")
                        GZEDatesService.shared.errorMessage.value = "service.chat.invalidChatId".localized()
                        return
                    }
                    
                    GZEChatService.shared.openChat(presenter: topVC, viewModel: GZEChatViewModelDates(chat: chat, dateRequestId: dateRequest.id, mode: .client, username: recipient.username))
                }
            }
            
            ack.with()
        }

        self.on(.createChargeSuccess) { data, ack in
            guard let dateRequestJson = data[0] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) else {
                log.error("Unable to parse data[0], expected data[0] to be a dateRequest, found: \(data[0])")
                return
            }
            log.debug("Charge success on date request [id=\(dateRequest.id)]")

            GZEDatesService.shared.upsert(dateRequest: dateRequest)
            GZEDatesService.shared.sendLocationUpdate(to: dateRequest.sender.id)

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

        self.on(.dateStarted) { data, ack in
            guard let dateRequestJson = data[0] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) else {
                log.error("Unable to parse data[0], expected data[0] to be a dateRequest, found: \(data[0])")
                return
            }
            log.debug("Date started on date request [id=\(dateRequest.id)]")

            GZEDatesService.shared.upsert(dateRequest: dateRequest)
            GZEDatesService.shared.stopSendingLocationUpdates()

            ack.with()
        }

        self.on(.dateEnded) { data, ack in
            guard let dateRequestJson = data[0] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) else {
                log.error("Unable to parse data[0], expected data[0] to be a dateRequest, found: \(data[0])")
                return
            }
            log.debug("Date started on date request [id=\(dateRequest.id)]")

            GZEDatesService.shared.upsert(dateRequest: dateRequest)

            ack.with()
        }
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
