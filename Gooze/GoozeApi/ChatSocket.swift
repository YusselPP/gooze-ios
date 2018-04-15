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
            
            guard let chatJson = data[1] as? JSON, let chat = GZEChat(json: chatJson) else {
                log.error("Unable to parse data[1], expected data[1] to be a chatJson, found: \(data[1])")
                return
            }
            
            let username: String = data[2] as? String ?? ""
            log.debug("Message from username[\(username)] received")
            log.debug("Message: \(String(describing: message.toJSON()))")

            GZEChatService.shared.receive(message: message, chat: chat, username: username)
            
            ack.with()
        }
        
        self.on(.messageReceivedAck) {data, ack in
            guard let messageJson = data[0] as? JSON, let message = GZEChatMessage(json: messageJson) else {
                log.error("Unable to parse data[0], expected data[0] to be a messageJson, found: \(data[0])")
                return
            }
            log.debug("Recipient has received the message: \(String(describing: message.toJSON()))")
            
            GZEChatService.shared.upsert(message: message)
            
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
