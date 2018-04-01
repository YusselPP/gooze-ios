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
        case dateRequestResponseSent
        case dateRequestResponseReceived
    }

    static let namespace = "/dates"

    // MARK - init
    override init(socketURL: URL, config: SocketIOClientConfiguration) {
        super.init(socketURL: socketURL, config: config)
        log.debug("\(self) init")
        self.addEventHandlers()
    }

    private func addEventHandlers() {
        self.on(.dateRequestReceived) {data, ack in
            guard let dateRequestJson = data[0] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) else {
                log.error("Unable to parse data[0], expected data[0] to be a dateRequest, found: \(data[0])")
                return
            }
            log.debug("Date request received : \(String(describing: dateRequest.toJSON()))")

            var newSet = Set(GZEDatesService.shared.receivedRequests.value)
            let (inserted, _) = newSet.insert(dateRequest)

            if (inserted) {
                GZEDatesService.shared.receivedRequests.value = newSet
                GZEDatesService.shared.lastReceivedRequest.value = dateRequest
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
