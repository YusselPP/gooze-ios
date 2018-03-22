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
        self.on(.dateRequestReceived) {[weak self] data, ack in
            log.debug("data: \(data[0])")

            guard let userJson = data[0] as? JSON, let user = GZEUser(json: userJson) else { return }

            let message = "Date request from: \(String(describing: user.toJSON()))"

            log.debug(message)

            self?.dateRequestReceivedUser.value = user
            self?.topViewController?.displayMessage(GZEAppConfig.appTitle, "\(String(describing: user.username)) quiere contactarte")
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

    @discardableResult
    func on(_ clientEvent: DatesSocket.DateEvent, callback: @escaping NormalCallback) -> UUID {

        return on(clientEvent.rawValue, callback: callback)
    }

}
