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
import enum Result.NoError
import SwiftOverlays

class GZEChatViewModelDates: GZEChatViewModel {

    // MARK: - GZEChatViewModel
    var mode: GZEChatViewMode {
        didSet { changeMode(self.mode) }
    }
    let error = MutableProperty<String?>(nil)

    let username = MutableProperty<String?>(nil)
    let messages = MutableProperty<[GZEChatMessage]>([])
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

    var paymentViewModel: GZEPaymentMethodsViewModel? {
        return getPaymentViewModel()
    }

    var mapViewModel: GZEMapViewModel {
        return GZEMapViewModelDate(dateRequest: self.dateRequest, mode: self.mode)
    }
    
    let (showPaymentViewSignal, showPaymentViewObserver) = Signal<Bool, NoError>.pipe()
    let (showMapViewSignal, showMapViewObserver) = Signal<Void, NoError>.pipe()
    
    let chat: GZEChat
    
    func startObservers() {
        self.observeMessages()
        self.observeRequests()
        self.observeSocketEvents()
        self.observeRequestUpdates()
    }
    
    func stopObservers() {
        self.stopObservingSocketEvents()
        self.stopObservingRequests()
        self.stopObservingMessages()
        self.stopObs.send(value: ())
    }
    
    func retrieveHistory() {
        self.retrieveHistoryProducer?.start()
    }
    // End GZEChatViewModel protocol

    
    // MARK: - private properties
    // let dateRequestId: String
    
    var requestsObserver: Disposable?
    var messagesObserver: Disposable?
    var socketEventsObserver: Disposable?
    var (stopSignal, stopObs) = Signal<Void, NoError>.pipe()
    
    var retrieveHistoryProducer: SignalProducer<Void, GZEError>?
    
    let setAmountButtonTitle = "vm.datesChat.setAmountButtonTitle".localized().uppercased()
    let acceptAmountButtonTitle = "vm.datesChat.acceptAmountButtonTitle".localized().uppercased()
    let dateButtonTitle = "vm.datesChat.dateButtonTitle".localized().uppercased()
    let errorDigitsOnly = "vm.datesChat.error.digitsOnly".localized()
    let errorPositiveNumber = "vm.datesChat.error.positiveNumber".localized()
    let amount = MutableProperty<Double?>(nil)
    let dateRequest: MutableProperty<GZEDateRequest>
    
    
    // MARK: - init
    init(chat: GZEChat, dateRequest: MutableProperty<GZEDateRequest>, mode: GZEChatViewMode, username: String) {
        self.mode = mode
        self.chat = chat
        self.dateRequest = dateRequest
        self.username.value = username
        
        log.debug("\(self) init")

        self.setAmount(self.dateRequest.value.amount)

        log.debug("active request: \(dateRequest)")
        
        self.changeMode(self.mode)

        let topAction = self.createTopAccessoryButtonAction()
        topAction.values.observeValues{[weak self] dateRequest in
            guard let this = self else {return}
            this.dateRequest.value = dateRequest
            this.setAmount(dateRequest.amount)
        }

        self.topButtonAction = CocoaAction(self.createTopButtonAction())
        self.topAccessoryButtonAction = CocoaAction(topAction)
        self.sendButtonAction = CocoaAction(self.createSendAction())
        
        self.retrieveHistoryProducer = SignalProducer {[weak self] sink, disposable in
            log.debug("retrieve history producer called")
            guard let this = self else {return}
            GZEChatService.shared.retrieveHistory(chatId: this.chat.id)
            sink.sendCompleted()
        }.debounce(60, on: QueueScheduler.main)

        if mode == .gooze {
            self.amount <~ self.topTextInput.map{[weak self] amountText -> Double? in
                if let amountText = amountText, !amountText.isEmpty {
                    guard let amountDouble = Double(amountText) else {
                        self?.error.value = self?.errorDigitsOnly
                        return nil
                    }

                    guard amountDouble > 0 else {
                        self?.error.value = self?.errorPositiveNumber
                        return nil
                    }

                    return amountDouble
                } else {
                    return nil
                }
            }
        }
        // self.getUpdatedRequest(dateRequestId)
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


            if (this.dateRequest.value.date) != nil {
                this.showMapView()
                return SignalProducer.empty
            }

            log.debug("mode: \(this.mode)")
            
            switch this.mode {
            case .client:
                this.showPaymentView()
            case .gooze:
                this.topTextInputIsHidden.value = false
            }

            return SignalProducer.empty
        }
    }
    
    private func createTopAccessoryButtonAction() -> Action<Void, GZEDateRequest, GZEError> {
        return Action(enabledIf: topAccessoryButtonEnabled) {[weak self] () -> SignalProducer<GZEDateRequest, GZEError> in
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
                    dateRequestId: this.dateRequest.value.id,
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

            guard !this.dateRequest.value.isBlocked else {
                let error = GZEError.message(text: "vm.datesChat.error.sendMessage.unavailable", args: [this.username.value ?? ""])
                this.error.value = error.localizedDescription
                return SignalProducer(error: error)
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
                dateRequest: this.dateRequest.value,
                mode: mode.rawValue
            )
            
            this.inputMessage.value = ""

            return SignalProducer.empty
        }
    }

    private func observeRequestUpdates() {
        if self.mode == .gooze {
            // validate max double val
            SignalProducer.combineLatest(
                self.amount.producer,
                self.dateRequest.producer
                )
                .take(until: self.stopSignal)
                .startWithValues{[weak self] (amount, dateRequest) in
                    guard let this = self else {return}

                    if dateRequest.date != nil {
                        this.topAccessoryButtonIsHidden.value = true
                        this.topButtonTitle.value = this.dateButtonTitle

                    } else if let amount = amount, let formattedAmount = GZENumberHelper.shared.currencyFormatter.string(from: NSNumber(value: amount)) {
                        this.topAccessoryButtonIsHidden.value = false
                        this.topButtonTitle.value = "\(formattedAmount) MXN"
                    } else {
                        this.topAccessoryButtonIsHidden.value = true
                        this.topButtonTitle.value = this.setAmountButtonTitle
                    }
            }
        } else {
            SignalProducer.combineLatest(
                self.amount.producer,
                self.dateRequest.producer
                )
                .take(until: self.stopSignal)
                
                .startWithValues{[weak self] (amount, dateRequest) in
                    guard let this = self else {return}

                    if dateRequest.date != nil {
                        this.topButtonIsHidden.value = false
                        this.topButtonTitle.value = this.dateButtonTitle

                    } else if let amount = amount, let formattedAmount = GZENumberHelper.shared.currencyFormatter.string(from: NSNumber(value: amount)) {
                        this.topButtonIsHidden.value = false
                        this.topButtonTitle.value =  "\(String(format: this.acceptAmountButtonTitle, formattedAmount)) MXN"
                    } else {
                        this.topButtonIsHidden.value = true
                        this.topButtonTitle.value =  ""
                    }
            }
        }
    }
    
    private func observeRequests() {
        // guard self.mode == .client else {return}
        
        self.stopObservingRequests()
        self.requestsObserver = (
            Signal.merge([
                GZEDatesService.shared.lastSentRequest.signal,
                GZEDatesService.shared.lastReceivedRequest.signal
            ])
                .skipNil()
                .filter{[weak self] in
                    guard let this = self else { return false }
                    log.debug("filter called: \(String(describing: $0.id)) \(String(describing: this.dateRequest.value.id))")
                    return $0.id == this.dateRequest.value.id
                }
                .observeValues {[weak self] updatedDateRequest in
                    log.debug("updatedDateRequest: \(String(describing: updatedDateRequest))")
                    guard let this = self else { log.error("self was disposed"); return }
                    this.dateRequest.value = updatedDateRequest
                    this.setAmount(updatedDateRequest.amount)
                }
        )
    }

    private func setAmount(_ amount: Double?) {
        self.amount.value = amount
        if let amount = amount {
            self.topTextInput.value = "\(amount)"
        } else {
            self.topTextInput.value = nil
        }
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
            return $0[this.chat.id]?.sorted(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending }) ?? []
        }
        GZEChatService.shared.retrieveHistory(chatId: chat.id)
    }
    
    private func stopObservingMessages() {
        log.debug("stop observing messages")
        if self.messagesObserver != nil {
            GZEChatService.shared.clear(chatId: self.chat.id)
            self.messagesObserver?.dispose()
            self.messagesObserver = nil
        }
    }
    
    private func observeSocketEvents() {
        log.debug("start observing socket events")
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
                this.getUpdatedRequest(this.dateRequest.value.id)
                GZEChatService.shared.retrieveNewMessages(chatId: this.chat.id)
            }
    }
    
    private func stopObservingSocketEvents() {
        log.debug("stop observing SocketEvents")
        if self.socketEventsObserver != nil {
            self.socketEventsObserver?.dispose()
            self.socketEventsObserver = nil
        }
    }

    private func getUpdatedRequest(_ dateRequestId: String?) {
        guard let dateRequestId = dateRequestId else {return}

        SwiftOverlays.showBlockingWaitOverlay()

        GZEDatesService.shared.find(byId: dateRequestId)
            .start{event in
                log.debug("find request event received: \(event)")

                SwiftOverlays.removeAllBlockingOverlays()

                switch event {
                // case .value(let dateRequest): handled by request observer
                case .failed(let error):
                    log.error(error.localizedDescription)
                default: break
                }
        }
    }
    
    private func showPaymentView() {
        self.showPaymentViewObserver.send(value: true)
    }

    private func getPaymentViewModel() -> GZEPaymentMethodsViewModelPay? {
        guard let sender = GZEAuthService.shared.authUser else {
            log.error("authUser is nil")
            return nil
        }

        guard let amount = self.amount.value else {
            log.error("amount is nil")
            return nil
        }

        var mode: GZEChatViewMode
        switch self.mode {
        case .client: mode = .gooze
        case .gooze: mode = .client
        }

        return GZEPaymentMethodsViewModelPay(
            amount: amount,
            dateRequest: self.dateRequest,
            senderId: sender.id,
            username: sender.username,
            chat: self.chat,
            mode: mode
        )
    }

    private func showMapView() {
        self.showMapViewObserver.send(value: ())
    }
    
    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
