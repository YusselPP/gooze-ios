//
//  ChatSocket.swift
//  Gooze
//
//  Created by Yussel on 3/19/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import SocketIO
import Gloss

class ChatSocket: GZESocket {
    enum ChatEvent: String {
        case sendMessage
        case messageReceived
        case messageReceivedAck
        
        case retrieveHistory
    }

    static let namespace = "/chat"

    // MARK - init
    override init(socketURL: URL, config: SocketIOClientConfiguration) {
        super.init(socketURL: socketURL, config: config)
        log.debug("\(self) init")
        self.addEventHandlers()
    }

    private func addEventHandlers() {
        log.debug("adding chat socket handlers")
        self.on(.messageReceived) {data, ack in
            guard let messageJson = data[0] as? JSON, let message = GZEChatMessage(json: messageJson) else {
                log.error("Unable to parse data[0], expected data[0] to be a messageJson, found: \(data[0])")
                return
            }
            log.debug("Message received : \(String(describing: message.toJSON()))")

            GZEChatService.shared.addReceivedMessage(message)
            
            ack.with()
        }
        
        self.on(.dateRequestReceivedAck) {data, ack in
            guard let messageJson = data[0] as? JSON, let message = GZEChatMessage(json: messageJson) else {
                log.error("Unable to parse data[0], expected data[0] to be a messageJson, found: \(data[0])")
                return
            }
            log.debug("Message received : \(String(describing: message.toJSON()))")
            
            GZEChatService.shared.addReceivedMessage(message)
            
            ack.with()
        }
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

    func emitWithAck(_ clientEvent: ChatSocket.ChatEvent, _ items: SocketData...) -> OnAckCallback {

        return emitWithAck(clientEvent.rawValue, items)
    }

    @discardableResult
    func on(_ clientEvent: ChatSocket.ChatEvent, callback: @escaping NormalCallback) -> UUID {

        return on(clientEvent.rawValue, callback: callback)
    }

}
