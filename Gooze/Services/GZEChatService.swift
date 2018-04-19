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
    
    let messagesChunkSize = 20
    let messages = MutableProperty<[String: [GZEChatMessage]]>([:])

    let errorMessage = MutableProperty<String?>(nil)

    var chatSocket: ChatSocket? {
        return GZESocketManager.shared[ChatSocket.namespace] as? ChatSocket
    }
    
    let chatEventEmmiter = MutableProperty<CollectionEvent?>(nil)
    
    var activeChatId: String?

    override init() {
        super.init()
    }
    
    func retrieveHistory(chatId: String) {
        log.debug("Retrieving messages history...")
        
        guard let chatSocket = self.chatSocket else {
            log.error("Chat socket not found")
            return
        }
        
        // let offset = (messages.value[chatId]?.count ?? 0) //+ messagesChunkSize
        let olderMessageDate: Date = self.messages.value[chatId]?.first?.createdAt ?? Date()
        let olderMessageDateJson = GZEApi.dateFormatter.string(from: olderMessageDate)
        
        chatSocket.emitWithAck(.retrieveHistory, chatId, olderMessageDateJson, messagesChunkSize).timingOut(after: 5) {[weak self] data in
            //log.debug("Message sent. Ack data: \(data)")
            
            if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                log.error("No ack received from server")
                return
            }
            
            if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {
                
                log.error("\(String(describing: error.toJSON()))")
                
            } else if
                let historyMessagesJson = data[1] as? [JSON],
                let historyMessages = [GZEChatMessage].from(jsonArray: historyMessagesJson)
            {
                if historyMessages.count <= 0 {
                    log.debug("There's no more messages in the chat history")
                    return
                }
                
                if var chat = self?.messages.value[chatId] {
                    log.debug("chat found inserting new messages")
                    
                    chat.upsert(contentsOf: historyMessages, prepend: true) { $0 == $1 }
                    self?.messages.value[chatId] = chat
                    self?.chatEventEmmiter.value = .add(at: 0, count: historyMessages.count)
                    
                    log.debug("Messages history successfully retrieved")
                } else {
                    log.debug("chat not found, creating it")
                    
                    self?.messages.value[chatId] = historyMessages.reversed()
                    self?.chatEventEmmiter.value = .add(at: 0, count: historyMessages.count)
                }
            } else {
                log.error("Unable to parse data to expected objects")
            }
        }
    }
              
    func send(message: GZEChatMessage, username: String, chat: GZEChat, dateRequestId: String, mode: String) {
        log.debug("Sending message..\(String(describing: message.toJSON()))")
        guard let chatSocket = self.chatSocket else {
            log.error("Chat socket not found")
            return
        }

        guard let messageJson = message.toJSON() else {
            log.error("Failed to parse GZEChatMessage to JSON")
            return
        }
        
        guard let chatJson = chat.toJSON() else {
            log.error("Failed to parse GZEChat to JSON")
            return
        }

        self.upsert(message: message)
        chatSocket.emitWithAck(.sendMessage, messageJson, username, chatJson, dateRequestId, mode).timingOut(after: 5) {[weak self] data in
            log.debug("Message sent. Ack data: \(data)")
            
            if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                log.error("No ack received from server")
                return
            }
            
            if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {
                
                log.error("\(String(describing: error.toJSON()))")
                
            } else if let updatedMessageJson = data[1] as? JSON, let updatedMessage = GZEChatMessage(json: updatedMessageJson) {
                
                self?.upsert(message: updatedMessage) { $0 === message }
                log.debug("Message successfully sent")
                
            } else {
                log.error("Unable to parse data to expected objects")
            }
        }
    }
    
    func receive(message: GZEChatMessage, username: String, chat: GZEChat, dateRequestId: String, mode: GZEChatViewMode) {
        log.debug("adding received message")
        
        if self.activeChatId == nil || self.activeChatId! != message.chatId {
            clear(chatId: message.chatId)
            showNotification(chat: chat, dateRequestId: dateRequestId, mode: mode, username: username)
        } else {
            log.debug("Received message on active chat, notification won't be shown")
        }
        
        self.upsert(message: message)
    }
    
    func request(amount: Double, dateRequestId: String, senderId: String, username: String, chat: GZEChat, mode: GZEChatViewMode) -> SignalProducer<Bool, GZEError> {
        guard let chatSocket = self.chatSocket else {
            log.error("Chat socket not found")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }
        
        guard let chatJson = chat.toJSON() else {
            log.error("Failed to parse GZEChat to JSON")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }
        
        guard let messageJson = GZEChatMessage(text: "service.chat.amountRequestReceivedasdfasdfasdfasdfasdfasfdasdfasdf", senderId: senderId, chatId: chat.id, type: .info).toJSON() else {
            log.error("Failed to parse GZEChatMessage to JSON")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }
        
        return SignalProducer { sink, disposable in
            
            disposable.add {
                log.debug("requestAmount signal disposed")
            }
            
            chatSocket.emitWithAck(.requestAmount, messageJson, username, chatJson, dateRequestId, mode.rawValue, amount).timingOut(after: 5) {[weak self] data in
                log.debug("Message sent. Ack data: \(data)")
                
                if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                    log.error("No ack received from server")
                    sink.send(error: .datesSocket(error: .noAck))
                    return
                }
                
                if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {
                    
                    log.error("\(String(describing: error.toJSON()))")
                    sink.send(error: .repository(error: .UnexpectedError))
                    
                } else if let messageJson = data[1] as? JSON, let message = GZEChatMessage(json: messageJson) {
                    
                    self?.upsert(message: message)
                    sink.send(value: true)
                    sink.sendCompleted()
                    log.debug("Message successfully sent")
                    
                } else {
                    log.error("Unable to parse data to expected objects")
                    sink.send(error: .repository(error: .UnexpectedError))
                }
            }
        }
    }

    func upsert(message: GZEChatMessage, comparator: ((GZEChatMessage) -> Bool)? = nil) {
        var resolvedComparator: (GZEChatMessage) -> Bool
        var messages = self.messages.value
        var currentChatMessages: [GZEChatMessage]
        var inserted: Bool

        let chatId = message.chatId
        
        if comparator == nil {
            resolvedComparator = { $0 == message }
        } else {
            resolvedComparator = comparator!
        }

        if
            messages[chatId] != nil
        {
            log.debug("Chat[id=\(chatId)] exists, new messages will be appended")
            currentChatMessages = messages[chatId]!
            inserted = currentChatMessages.upsert(message, comparator: resolvedComparator)
        } else {
            log.debug("Chat[id=\(chatId)] not found, creating the chat with the new messages")
            currentChatMessages = [message]
            inserted = true
        }
        
        messages[chatId] = currentChatMessages
        self.messages.value = messages
        if inserted {
            self.chatEventEmmiter.value = .add(at: currentChatMessages.count - 1, count: 1)
        }
    }
    
    func clear(chatId: String) {
        if let messagesCount = self.messages.value[chatId]?.count {
            self.chatEventEmmiter.value = .remove(at: 0, count: messagesCount)
        }
        self.messages.value[chatId] = []
    }
    
    func showNotification(chat: GZEChat, dateRequestId: String, mode: GZEChatViewMode, username: String) {
        if let topVC = UIApplication.topViewController() {
            let messageReceived = String(format: "service.chat.messageReceived".localized(), username)
            
            GZEAlertService.shared.showTopAlert(text: messageReceived) {
                //TODO: manage chat mode with client mode property instead of sending to vm
                GZEChatService.shared.openChat(
                    presenter: topVC,
                    viewModel: GZEChatViewModelDates(chat: chat, dateRequestId: dateRequestId, mode: mode, username: username)
                )
            }
        } else {
            log.error("Unnable to get top view controller")
        }
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
