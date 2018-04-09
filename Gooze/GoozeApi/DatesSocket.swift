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
        case dateRequestSent
        case dateRequestReceived
        case dateRequestReceivedAck
        
        case acceptRequest
        case requestAccepted
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
                    GZEChatService.shared.openChat(presenter: topVC, viewModel: GZEChatViewModelDates(recipient: recipient))
                }
            }
            
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
