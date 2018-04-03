//
//  GZEChatService.swift
//  Gooze
//
//  Created by Yussel on 3/31/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import SocketIO
import ReactiveSwift

class GZEChatService: NSObject {
    static let shared = GZEChatService()

    let lastReceivedMessage = MutableProperty<GZEChatMessage?>(nil)
    let receivedMessages = MutableProperty<[GZEChatMessage]>([])

    var chatSocket: ChatSocket? {
        return GZESocketManager.shared[ChatSocket.namespace] as? ChatSocket
    }

    override init() {
        super.init()
    }

    func send(message: GZEChatMessage) {
        log.debug("Sending message..\(String(describing: message.toJSON()))")
        guard let chatSocket = self.chatSocket else {
            log.error("Chat socket not found")
            return
        }

        guard let messageJson = message.toJSON() else {
            log.error("Failed to parse GZEChatMessage to JSON")
            return
        }

        self.addReceivedMessage(message: message)
        chatSocket.emitWithAck(.sendMessage, messageJson).timingOut(after: 5) { data in
            log.debug("Message sent. Ack data: \(data)")
        }
    }
    
    func addReceivedMessage(message: GZEChatMessage) {
        var newMessages = Array(self.receivedMessages.value)
        newMessages.append(message)
        self.receivedMessages.value = newMessages
    }
}
