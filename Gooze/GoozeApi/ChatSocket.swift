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
        
        case requestAmount
        case amountRequestReceived
        
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
            
            let username: String = data[1] as? String ?? ""
            
            guard let chatJson = data[2] as? JSON, let chat = GZEChat(json: chatJson) else {
                log.error("Unable to parse data[2], expected data[2] to be a chatJson, found: \(data[2])")
                return
            }
            
            guard let dateRequestId = data[3] as? String else {
                log.error("Unable to parse data[3], expected data[3] to be a String, found: \(data[3])")
                return
            }
            
            guard let mode = GZEChatViewMode(rawValue: (data[4] as? String) ?? "") else {
                log.error("Unable to parse data[4], expected data[4] to be a chatJson, found: \(data[4])")
                return
            }
            
            log.debug("Message from username[\(username)] received")
            log.debug("Message: \(String(describing: message.toJSON()))")

            GZEChatService.shared.receive(message: message, username: username, chat: chat, dateRequestId: dateRequestId, mode: mode)
            
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
        
        self.on(.amountRequestReceived) {data, ack in

            guard let dateRequestJson = data[0] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson) else {
                log.error("Unable to parse data[0], expected data[0] to be a GZEDateRequest, found: \(data[0])")
                return
            }

            log.debug("Amount request received")
            
            GZEDatesService.shared.sentRequests.value.upsert(dateRequest){$0 == dateRequest}
            
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
