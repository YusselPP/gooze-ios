//
//  GZEChatService.swift
//  Gooze
//
//  Created by Yussel on 3/31/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import SocketIO
import ReactiveSwift
import Gloss

class GZEChatService: NSObject {
    static let shared = GZEChatService()

    let receivedMessages = MutableProperty<[String: [GZEChatMessage]]>([:])


    var chatSocket: ChatSocket? {
        return GZESocketManager.shared[ChatSocket.namespace] as? ChatSocket
    }

    var activeRecipientId: String?

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

        self.addSentMessage(message)
        chatSocket.emitWithAck(.sendMessage, messageJson).timingOut(after: 5) {[weak self] data in
            log.debug("Message sent. Ack data: \(data)")
            
            if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                log.error("No ack received from server")
                return
            }
            
            if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {
                
                log.error("\(String(describing: error.toJSON()))")
                
            } else if let updatedMessageJson = data[1] as? JSON, let updatedMessage = GZEChatMessage(json: updatedMessageJson) {
                
                self?.addSentMessage(updatedMessage)
                log.debug("Message successfully sent")
                
            } else {
                log.error("Unable to parse data to expected objects")
            }
        }
    }

    func addSentMessage(_ message: GZEChatMessage) {
        var receivedMessages = self.receivedMessages.value
        var recipientMessages: [GZEChatMessage]

        let recipientId = message.recipient.id 

        if
            receivedMessages[recipientId] != nil,
            let activeRecipientId = self.activeRecipientId,
            activeRecipientId == recipientId
        {
            log.debug("Appending message to current sender messages")
            recipientMessages = receivedMessages[recipientId]!
        } else {
            log.debug("No current messages found for this recipient, creating messages array")
            recipientMessages = []
        }

        recipientMessages.upsert(message) {$0 == message}
        receivedMessages[recipientId] = recipientMessages
        self.receivedMessages.value = receivedMessages
    }
    
    func addReceivedMessage(_ message: GZEChatMessage) {
        var receivedMessages = self.receivedMessages.value
        var senderMessages: [GZEChatMessage]

        let senderId = message.sender.id

        if
            receivedMessages[senderId] != nil,
            let activeRecipientId = self.activeRecipientId,
            activeRecipientId == senderId
        {
            log.debug("Appending message to current sender messages")
            senderMessages = receivedMessages[senderId]!
        } else {
            log.debug("No current messages found for this sender, creating messages array")
            senderMessages = []

            if let topVC = UIApplication.topViewController() {
                let messageReceived = String(format: "service.chat.messageReceived".localized(), message.sender.username)
                GZEAlertService.shared.showTopAlert(text: messageReceived) {
                    //TODO: manage chat mode with client mode property instead of sending to vm
                    GZEChatService.shared.openChat(presenter: topVC, viewModel: GZEChatViewModelDates(recipient: message.sender))
                }
            }
        }

        senderMessages.upsert(message) {$0 == message}
        receivedMessages[senderId] = senderMessages
        self.receivedMessages.value = receivedMessages
    }

    func openChat(presenter: UIViewController, viewModel: GZEChatViewModel) {
        // Open chat
        log.debug("Trying to show chat controller...")
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        if let chatController = mainStoryboard.instantiateViewController(withIdentifier: "GZEChatViewController") as? GZEChatViewController {

            log.debug("chat controller instantiated. Setting up its view model")
            // Set up initial view model
            chatController.viewModel = viewModel
            chatController.onDismissTapped = {
                presenter.dismiss(animated: true)
            }
            presenter.present(chatController, animated: true)
        } else {
            log.error("Unable to instantiate GZEChatViewController")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
        }
    }
}
