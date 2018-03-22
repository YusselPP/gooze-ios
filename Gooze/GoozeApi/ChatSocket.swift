//
//  ChatSocket.swift
//  Gooze
//
//  Created by Yussel on 3/19/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import SocketIO

class ChatSocket: GZESocket {
    enum ChatEvent: String {
        case event
    }

    static let namespace = "/chat"

    // MARK - init
    override init(socketURL: URL, config: SocketIOClientConfiguration) {
        super.init(socketURL: socketURL, config: config)
        log.debug("\(self) init")
        self.addEventHandlers()
    }

    private func addEventHandlers() {

    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}

extension SocketIOClient {

    func emit(_ clientEvent: ChatSocket.ChatEvent, _ items: SocketData...) {

        emit(clientEvent.rawValue, items)
    }

    @discardableResult
    func on(_ clientEvent: ChatSocket.ChatEvent, callback: @escaping NormalCallback) -> UUID {

        return on(clientEvent.rawValue, callback: callback)
    }

}
