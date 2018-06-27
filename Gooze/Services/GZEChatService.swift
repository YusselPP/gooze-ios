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
    let lastMessage = MutableProperty<GZEChatMessage?>(nil)

    let errorMessage = MutableProperty<String?>(nil)

    var chatSocket: ChatSocket? {
        return GZESocketManager.shared[ChatSocket.namespace] as? ChatSocket
    }

    let chatMessageRepository: GZEChatMessageRepositoryProtocol = GZEChatMessageApiRepository()
    
    var activeChatId: String? {
        didSet {
            activeChatDidSet()
        }
    }

    override init() {
        super.init()
    }

    func retrieveNewMessages(chatId: String) {
        log.debug("Retrieving new messages...")

        guard let chatSocket = self.chatSocket else {
            log.error("Chat socket not found")
            return
        }

        guard let lastMessage = self.messages.value[chatId]?.last else {
            self.retrieveHistory(chatId: chatId)
            return
        }

        let lastMessageDate: Date = lastMessage.createdAt
        let lastMessageDateJson = GZEApi.dateFormatter.string(from: lastMessageDate)

        let filter =
            [
                "where": [
                    "createdAt": [
                        "gt": lastMessageDateJson
                    ]
                ],
                "limit": 100,
                "order": "createdAt DESC"

            ] as [String : Any]

        chatSocket.emitWithAck(.retrieveMessages, chatId, filter).timingOut(after: GZESocket.ackTimeout) {[weak self] data in
            //log.debug("Message sent. Ack data: \(data)")

            if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                log.error("No ack received from server")
                return
            }

            if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {

                log.error("\(String(describing: error.toJSON()))")

            } else if
                let newMessagesJson = data[1] as? [JSON],
                let newMessages = [GZEChatMessage].from(jsonArray: newMessagesJson)
            {
                if newMessages.count <= 0 {
                    log.debug("There's no more new messages")
                    return
                }

                let reversedNewMessages: [GZEChatMessage] = newMessages.reversed()

                if var chat = self?.messages.value[chatId] {
                    log.debug("chat found, current messages count: \(chat.count). Inserting \(newMessages.count) new messages")

                    chat.upsert(contentsOf: reversedNewMessages) { $0 == $1 }
                    self?.messages.value[chatId] = chat

                    log.debug("New messages successfully retrieved")
                } else {
                    log.debug("chat not found, creating it")

                    self?.messages.value[chatId] = reversedNewMessages
                }
            } else {
                log.error("Unable to parse data to expected objects")
            }
        }
    }

    func retrieveHistory(chatId: String) {
        log.debug("Retrieving messages history...")

        guard let chatSocket = self.chatSocket else {
            log.error("Chat socket not found")
            return
        }

        let olderMessageDate: Date = self.messages.value[chatId]?.first?.createdAt ?? Date()
        let olderMessageDateJson = GZEApi.dateFormatter.string(from: olderMessageDate)

        let filter =
            [
                "where": [
                    "createdAt": [
                        "lt": olderMessageDateJson
                    ]
                ],
                "limit": messagesChunkSize,
                "order": "createdAt DESC"
            ] as [String : Any]

        chatSocket.emitWithAck(.retrieveMessages, chatId, filter).timingOut(after: GZESocket.ackTimeout) {[weak self] data in
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
                    log.debug("chat found, current messages count: \(chat.count). Inserting \(historyMessages.count) new messages")

                    chat.upsert(contentsOf: historyMessages, prepend: true) { $0 == $1 }
                    self?.messages.value[chatId] = chat

                    log.debug("Messages history successfully retrieved")
                } else {
                    log.debug("chat not found, creating it")

                    self?.messages.value[chatId] = historyMessages.reversed()
                }
            } else {
                log.error("Unable to parse data to expected objects")
            }
        }
    }

    func send(message: GZEChatMessage, username: String, chat: GZEChat, dateRequest: GZEDateRequest, mode: String) {
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

        guard let dateRequestJson = dateRequest.toJSON() else {
            log.error("Failed to parse GZEDateRequest to JSON")
            return
        }

        self.upsert(message: message)
        chatSocket.emitWithAck(.sendMessage, messageJson, username, chatJson, dateRequestJson, mode).timingOut(after: GZESocket.ackTimeout) {[weak self] data in
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
    
    func receive(message: GZEChatMessage, username: String, chat: GZEChat, dateRequest: GZEDateRequest, mode: GZEChatViewMode) {
        log.debug("adding received message")
        
        if self.activeChatId == nil || self.activeChatId! != message.chatId {
            clear(chatId: message.chatId)
            showNotification(chat: chat, dateRequest: dateRequest, mode: mode, username: username)
        } else {
            log.debug("Received message on active chat, notification won't be shown")
        }
        
        self.upsert(message: message)
    }
    
    func request(amount: Double, dateRequestId: String, senderId: String, username: String, chat: GZEChat, mode: GZEChatViewMode, senderUsername: String) -> SignalProducer<GZEDateRequest, GZEError> {
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
        
        let formattedAmount = GZENumberHelper.shared.currencyFormatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        
        guard let messageJson = GZEChatMessage(text: "service.chat.amountRequest.received|\(senderUsername)|\(formattedAmount)", senderId: senderId, chatId: chat.id, type: .info).toJSON() else {
            log.error("Failed to parse GZEChatMessage to JSON")
            self.errorMessage.value = DatesSocketError.unexpected.localizedDescription
            return SignalProducer(error: .datesSocket(error: .unexpected))
        }
        
        return SignalProducer { sink, disposable in
            
            disposable.add {
                log.debug("requestAmount signal disposed")
            }
            
            chatSocket.emitWithAck(.requestAmount, messageJson, username, chatJson, dateRequestId, mode.rawValue, amount).timingOut(after: GZESocket.ackTimeout) {[weak self] data in
                log.debug("Message sent. Ack data: \(data)")
                
                if let data = data[0] as? String, data == SocketAckStatus.noAck.rawValue {
                    log.error("No ack received from server")
                    sink.send(error: .datesSocket(error: .noAck))
                    return
                }
                
                if let errorJson = data[0] as? JSON, let error = GZEApiError(json: errorJson) {
                    
                    log.error("\(String(describing: error.toJSON()))")
                    sink.send(error: .repository(error: .UnexpectedError))
                    
                } else if let messageJson = data[1] as? JSON, let message = GZEChatMessage(json: messageJson),
                    let dateRequestJson = data[2] as? JSON, let dateRequest = GZEDateRequest(json: dateRequestJson)
                {
                    
                    self?.upsert(message: message)
                    sink.send(value: dateRequest)
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
            currentChatMessages.upsert(message, comparator: resolvedComparator)
        } else {
            log.debug("Chat[id=\(chatId)] not found, creating the chat with the new messages")
            currentChatMessages = [message]
        }

        messages[chatId] = currentChatMessages
        self.messages.value = messages
        self.lastMessage.value = message
    }
    
    func clear(chatId: String) {
        if let messagesCount = self.messages.value[chatId]?.count, messagesCount > 0 {
            self.messages.value[chatId] = []
        }
        log.debug("chat cleared, current messages count: \(self.messages.value[chatId]?.count ?? 0)")
    }
    
    func showNotification(chat: GZEChat, dateRequest: GZEDateRequest, mode: GZEChatViewMode, username: String) {
        let messageReceived = String(format: "service.chat.messageReceived".localized(), username)

        GZEAlertService.shared.showTopAlert(text: messageReceived) {
            var requestProperty: MutableProperty<GZEDateRequest>
            if let activeRequest = GZEDatesService.shared.activeRequest {
                requestProperty = activeRequest
            } else {
                requestProperty = MutableProperty(dateRequest)
            }
            //TODO: manage chat mode with client mode property instead of sending to vm
            GZEChatService.shared.openChat(
                viewModel: GZEChatViewModelDates(chat: chat, dateRequest: requestProperty, mode: mode, username: username)
            )
        }
    }

    func openChat(viewModel: GZEChatViewModel, completion: (() -> Void)? = nil) {
        // Open chat
        log.debug("Trying to show chat controller...")
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        guard let navController = UIApplication.shared.delegate?.window??.rootViewController as? UINavigationController else {
            log.error("Unable to instantiate UINavigationController")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
            completion?()
            return
        }

        if let topViewController = navController.topViewController, topViewController.isKind(of: GZEMapViewController.self) {
            log.debug("Top view controller is GZEMapViewController, disposing it to show chat view controller")
            navController.popViewController(animated: true, completion: completion)
            return
        }

        guard let chatController = mainStoryboard.instantiateViewController(withIdentifier: "GZEChatViewController") as? GZEChatViewController else {
            log.error("Unable to instantiate GZEChatViewController")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
            completion?()
            return
        }

        log.debug("chat controller instantiated. Setting up its view model")
        chatController.viewModel = viewModel
        navController.pushViewController(chatController, animated: true, completion: completion)
    }

    func activeChatDidSet() {
        guard let activeChatId = self.activeChatId else {
            log.debug("activeChatId set to nil")
            return
        }

        log.debug("setting messages from chat: \(activeChatId) with read status")
        chatMessageRepository
            .setRead(chatId: activeChatId)
            .start{[weak self] in
                switch $0 {
                case .value(let count):
                    log.debug("updated messages: \(count)")
                case .failed(let error):
                    log.error(error)
                    self?.errorMessage.value = error.localizedDescription
                default: break
                }
            }
    }

    func cleanup() {
        self.activeChatId = nil
        self.messages.value = [:]
    }

    // MARK: deinit
    deinit {
        log.debug("\(self) disposed")
    }
}
