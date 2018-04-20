//
//  GZEDatesChatViewModel.swift
//  Gooze
//
//  Created by Yussel on 3/31/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZEChatViewModelDates: GZEChatViewModel {

    // MARK: - GZEChatViewModel
    var mode: GZEChatViewMode {
        didSet { changeMode(self.mode) }
    }
    let error = MutableProperty<String?>(nil)

    let username = MutableProperty<String?>(nil)
    let messages = MutableProperty<[GZEChatMessage]>([])
    let messagesEvents = MutableProperty<CollectionEvent?>(nil)
    let backgroundImage = MutableProperty<URLRequest?>(nil)

    let topButtonTitle = MutableProperty<String>("")
    let topButtonEnabled = MutableProperty<Bool>(true)
    let topButtonIsHidden = MutableProperty<Bool>(true)
    var topButtonAction: CocoaAction<GZEButton>?
    
    let topAccessoryButtonEnabled = MutableProperty<Bool>(true)
    let topAccessoryButtonIsHidden = MutableProperty<Bool>(true)
    var topAccessoryButtonAction: CocoaAction<UIButton>?
    
    let topTextInput = MutableProperty<String?>(nil)
    let topTextInputIsHidden = MutableProperty<Bool>(true)

    let inputMessage = MutableProperty<String?>(nil)
    let sendButtonImage = MutableProperty<UIImage?>(nil)
    let sendButtonEnabled = MutableProperty<Bool>(true)
    var sendButtonAction: CocoaAction<UIButton>!
    
    let chat: GZEChat
    
    func startObservers() {
        self.observeMessages()
        self.observeRequests()
        self.observeSocketEvents()
    }
    
    func stopObservers() {
        self.stopObservingSocketEvents()
        self.stopObservingRequests()
        self.stopObservingMessages()
    }
    
    func retrieveHistory() {
        self.retrieveHistoryProducer?.start()
    }
    // End GZEChatViewModel protocol

    
    // MARK: - private properties
    let dateRequestId: String
    
    var requestsObserver: Disposable?
    var messagesObserver: Disposable?
    var socketEventsObserver: Disposable?
    var messagesEventsObserver: Disposable?
    
    var retrieveHistoryProducer: SignalProducer<Void, GZEError>?
    
    let setAmountButtonTitle = "vm.datesChat.setAmountButtonTitle".localized().uppercased()
    let acceptAmountButtonTitle = "vm.datesChat.acceptAmountButtonTitle".localized().uppercased()
    let amount = MutableProperty<Double?>(nil)
    
    
    
    // MARK: - init
    init(chat: GZEChat, dateRequestId: String, mode: GZEChatViewMode, username: String) {
        self.mode = mode
        self.chat = chat
        self.dateRequestId = dateRequestId
        self.username.value = username
        
        log.debug("\(self) init")
        
        self.changeMode(self.mode)

        self.topButtonAction = CocoaAction(self.createTopButtonAction())
        self.topAccessoryButtonAction = CocoaAction(self.createTopAccessoryButtonAction())
        self.sendButtonAction = CocoaAction(self.createSendAction())
        
        self.retrieveHistoryProducer = SignalProducer {[weak self] sink, disposable in
            log.debug("retrieve history producer called")
            guard let this = self else {return}
            GZEChatService.shared.retrieveHistory(chatId: this.chat.id)
            sink.sendCompleted()
        }.debounce(60, on: QueueScheduler.main)
        
        GZEDatesService.shared.find(byId: dateRequestId)
        GZEChatService.shared.retrieveHistory(chatId: chat.id)
        
        if mode == .gooze {
            // validate max double val
            self.topButtonTitle <~ self.amount.map{[weak self] in
                guard let this = self else {return ""}
                if let amount = $0, let formattedAmount = GZENumberHelper.shared.currencyFormatter.string(from: NSNumber(value: amount)) {
                    this.topAccessoryButtonIsHidden.value = false
                    return "\(formattedAmount)"
                } else {
                    this.topAccessoryButtonIsHidden.value = true
                    return this.setAmountButtonTitle
                }
            }
            
            self.amount <~ self.topTextInput.map{ amountText -> Double? in
                if let amountText = amountText {
                    return Double(amountText)
                } else {
                    return nil
                }
            }
        } else {
            self.topButtonTitle <~ self.amount.map{[weak self] in
                guard let this = self else {return ""}
                if let amount = $0, let formattedAmount = GZENumberHelper.shared.currencyFormatter.string(from: NSNumber(value: amount)) {
                    this.topButtonIsHidden.value = false
                    return "\(String(format: this.acceptAmountButtonTitle, formattedAmount))"
                } else {
                    this.topButtonIsHidden.value = true
                    return ""
                }
            }
        }
    }
    
    private func changeMode(_ mode: GZEChatViewMode) {
        log.debug("changing chat mode: \(mode)")
        switch mode {
        case .client:
            topButtonTitle.value = ""
            topButtonIsHidden.value = true
        case .gooze:
            topButtonTitle.value = setAmountButtonTitle
            topButtonIsHidden.value = false
        }
    }

    // MARK: - Actions
    private func createTopButtonAction() -> Action<Void, Bool, GZEError> {
        return Action(enabledIf: topButtonEnabled) {[weak self] () -> SignalProducer<Bool, GZEError> in
            guard let this = self else {
                log.error("self disposed before executing action")
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }
            
            log.debug("mode: \(this.mode)")
            
            switch this.mode {
            case .client: break
            case .gooze:
                this.topTextInputIsHidden.value = false
            }

            return SignalProducer.empty
        }
    }
    
    private func createTopAccessoryButtonAction() -> Action<Void, Bool, GZEError> {
        return Action(enabledIf: topAccessoryButtonEnabled) {[weak self] () -> SignalProducer<Bool, GZEError> in
            guard let this = self else {
                log.error("self disposed before executing action")
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }
            
            guard let sender = GZEAuthService.shared.authUser else {
                log.error("sender is nil")
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }
            
            guard let amount = this.amount.value else {
                return SignalProducer(error: .validation(error: .required(fieldName: "amount")))
            }
            
            guard let username = this.username.value else {
                return SignalProducer(error: .validation(error: .required(fieldName: "username")))
            }
            
            switch this.mode {
            case .client: return SignalProducer.empty
            case .gooze:
                return GZEChatService.shared.request(
                    amount: amount,
                    dateRequestId: this.dateRequestId,
                    senderId: sender.id,
                    username: username,
                    chat: this.chat,
                    mode: .client,
                    senderUsername: sender.username
                )
            }
        }
    }

    private func createSendAction() -> Action<Void, Void, GZEError> {
        return Action(enabledIf: sendButtonEnabled) {[weak self] () -> SignalProducer<Void, GZEError> in
            guard let this = self else {
                log.error("self disposed before executing action")
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }

            guard let messageText = this.inputMessage.value else {
                return SignalProducer(error: .validation(error: .required(fieldName: "messageText")))
            }
            
            let messageTextTrim = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !messageTextTrim.isEmpty else {
                return SignalProducer(error: .validation(error: .required(fieldName: "messageText")))
            }
            
            guard let sender = GZEAuthService.shared.authUser else {
                log.error("sender is nil")
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }


            let message = GZEChatMessage(
                text: messageTextTrim,
                //sender: sender.toChatUser(),
                //recipient: this.recipient
                senderId: sender.id,
                chatId: this.chat.id
            )
            
            var mode: GZEChatViewMode
            switch this.mode {
            case .client: mode = .gooze
            case .gooze: mode = .client
            }

            GZEChatService.shared.send(
                message: message,
                username: sender.username,
                chat: this.chat,
                dateRequestId: this.dateRequestId,
                mode: mode.rawValue
            )
            
            this.inputMessage.value = ""

            return SignalProducer.empty
        }
    }
    
    private func observeRequests() {
        // guard self.mode == .client else {return}
        
        self.stopObservingRequests()
        self.requestsObserver = (
            SignalProducer.merge([
                GZEDatesService.shared.sentRequests.producer,
                GZEDatesService.shared.receivedRequests.producer
            ])
                .map{$0.first{[weak self] in
                    guard let this = self else { return false }
                    log.debug("filter called: \(String(describing: $0)) \(String(describing: this.dateRequestId))")
                    return $0.id == this.dateRequestId
                }}
                .skipNil()
                .skipRepeats()
                .startWithValues {[weak self] updatedDateRequest in
                    log.debug("updatedDateRequest: \(String(describing: updatedDateRequest))")
                    guard let this = self else { log.error("self was disposed"); return }
                    this.amount.value = updatedDateRequest.amount
                    if let amount = updatedDateRequest.amount {
                        this.topTextInput.value = "\(amount)"
                    } else {
                        this.topTextInput.value = nil
                    }
                }
        )
    }
    
    private func stopObservingRequests() {
        self.requestsObserver?.dispose()
        self.requestsObserver = nil
    }
    
    private func observeMessages() {
        log.debug("start observing messages")
        self.stopObservingMessages()
        self.messagesObserver = self.messages.bindingTarget <~ GZEChatService.shared.messages.map {[weak self] in
            guard let this = self else { log.error("self was disposed");  return [] }
            return $0[this.chat.id] ?? []
        }
        self.messagesEventsObserver = self.messagesEvents.bindingTarget <~ GZEChatService.shared.chatEventEmmiter
    }
    
    private func stopObservingMessages() {
        log.debug("stop observing messages")
        self.messagesObserver?.dispose()
        self.messagesObserver = nil
        self.messagesEventsObserver?.dispose()
        self.messagesEventsObserver = nil
    }
    
    private func observeSocketEvents() {
        stopObservingSocketEvents()
        self.socketEventsObserver = GZEDatesService.shared.dateSocket?
            .socketEventsEmitter
            .signal
            .skipNil()
            .filter { $0 == .authenticated }
            .observeValues {[weak self] _ in
                guard let this = self else {
                    log.error("self was disposed")
                    return
                }
                GZEDatesService.shared.find(byId: this.dateRequestId)
                GZEChatService.shared.retrieveHistory(chatId: this.chat.id)
                // TODO: should we retrieve al unreceived messages?
            }
    }
    
    private func stopObservingSocketEvents() {
        log.debug("stop observing SocketEvents")
        self.socketEventsObserver?.dispose()
        self.socketEventsObserver = nil
    }
    
    // MARK: - Deinitializers
    deinit {
        GZEChatService.shared.clear(chatId: self.chat.id)
        log.debug("\(self) disposed")
    }
}
