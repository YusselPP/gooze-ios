//
//  GZEProfileViewModelReadOnly.swift
//  Gooze
//
//  Created by Yussel on 3/5/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class GZEProfileViewModelReadOnly: NSObject, GZEProfileViewModel {

    // MARK - GZEProfileViewModel protocol
    var mode = GZEProfileMode.contact {
        didSet {
            log.debug("mode set: \(self.mode)")
            setMode()
        }
    }
    var dateRequest: GZEDateRequest? {
        didSet {
            log.debug("dateRequest didSet: \(String(describing: dateRequest))")
            setActionButtonTitle()
            setActionButtonState()
        }
    }
    var acceptRequestAction: Action<Void, GZEDateRequest, GZEError>!
    
    let error = MutableProperty<String?>(nil)

    let actionButtonTitle = MutableProperty<String>("")
    
    var chatViewModel: GZEChatViewModel? {
        log.debug("chatViewModel called")
        guard let chat = dateRequest?.chat else {
            log.error("Unable to open the chat, found nil chat on date request")
            error.value = "service.chat.invalidChatId".localized()
            return nil
        }
        
        return GZEChatViewModelDates(chat: chat, username: self.user.username)
    }
    weak var controller: UIViewController?
    
    
    func startObservers() {
        self.observeMessages()
        self.observeRequests()
    }
    
    func stopObservers() {
        // TODO: test that date requests continue updating correctly after this change
        self.stopObservingRequests()
        self.stopObservingMessages()
    }
    // End GZEProfileViewModel protocol
    
    
    let user: GZEUser
    
    let contactButtonTitle = "vm.profile.contactTitle".localized().uppercased()
    let acceptRequestButtonTitle = "vm.profile.acceptRequestTitle".localized().uppercased()
    let acceptedRequestButtonTitle = "vm.profile.acceptedRequestButtonTitle".localized().uppercased()
    let rejectedRequestButtonTitle = "vm.profile.rejectedRequestButtonTitle".localized().uppercased()
    let sentRequestButtonTitle = "vm.profile.sentRequestButtonTitle".localized().uppercased()
    let isContactButtonEnabled = MutableProperty<Bool>(false)

    var messagesObserver: Disposable?
    var requestsObserver: Disposable?

    // MARK - init
    init(user: GZEUser) {
        self.user = user
        super.init()
        log.debug("\(self) init")
        
        self.setMode()
        self.acceptRequestAction = self.createAcceptRequestAction()
        self.acceptRequestAction.events.observeValues {[weak self] in
            self?.onAcceptRequestAction($0)
        }
    }
    
    private func createAcceptRequestAction() -> Action<Void, GZEDateRequest, GZEError> {
        return Action(enabledIf: isContactButtonEnabled) {[weak self] in
            guard let this = self else {
                log.error("self disposed before used");
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }
            
            if this.mode == .request {
                if let dateRequest = this.dateRequest {
                    switch dateRequest.status {
                    case .sent,
                         .received:
                        return GZEDatesService.shared.acceptDateRequest(withId: this.dateRequest?.id)
                    case .accepted:
                        this.openChat()
                        return SignalProducer.empty
                    case .rejected:
                        return SignalProducer.empty
                    }
                } else {
                    return SignalProducer.empty
                }
                
            } else {
                if let dateRequest = this.dateRequest {
                    switch dateRequest.status {
                    case .sent,
                         .received:
                        break
                    case .accepted:
                        this.openChat()
                    case .rejected: // should not be received, defaulting to contact if happens
                        return GZEDatesService.shared.requestDate(to: this.user.id)
                    }
                } else {
                    return GZEDatesService.shared.requestDate(to: this.user.id)
                }
                return SignalProducer.empty
            }
        }
    }
    
    private func onAcceptRequestAction(_ event: Event<GZEDateRequest, GZEError>) {
        log.debug("event received: \(event)")
        switch event {
        case .value:
            switch self.mode {
            case .request: self.openChat()
            default: break// self.dateRequest = dateReq
            }
        case .failed(let error):
            onError(error)
        default: break
        }
    }
    
    private func onError(_ error: GZEError) {
        self.error.value = error.localizedDescription
    }
    
    private func setMode() {
        setActionButtonTitle()
        setActionButtonState()
    }
    
    private func setActionButtonTitle() {
        log.debug("set action button title called")
        if mode == .request {
            if let dateRequest = self.dateRequest {
                switch dateRequest.status {
                case .sent,
                     .received:
                    self.actionButtonTitle.value = self.acceptRequestButtonTitle
                case .accepted:
                     self.actionButtonTitle.value = self.acceptedRequestButtonTitle
                case .rejected:
                    self.actionButtonTitle.value = self.rejectedRequestButtonTitle
                }
            } else {
                isContactButtonEnabled.value = false
            }
        } else {
            if let dateRequest = self.dateRequest {
                switch dateRequest.status {
                case .sent,
                     .received:
                    self.actionButtonTitle.value = self.sentRequestButtonTitle
                case .accepted:
                    self.actionButtonTitle.value = self.acceptedRequestButtonTitle
                case .rejected: // should not be received, defaulting to contact if happens
                     self.actionButtonTitle.value = self.contactButtonTitle
                }
            } else {
                self.actionButtonTitle.value = self.contactButtonTitle
            }
        }
    }
    
    private func setActionButtonState() {
        log.debug("set action button state called")
        if mode == .request {
            if let dateRequest = self.dateRequest {
                switch dateRequest.status {
                    case .sent,
                         .received,
                         .accepted:
                    isContactButtonEnabled.value = true
                case .rejected:
                    isContactButtonEnabled.value = false
                }
            } else {
                isContactButtonEnabled.value = false
            }
        } else {
            if let dateRequest = self.dateRequest {
                switch dateRequest.status {
                case .sent,
                     .received:
                    isContactButtonEnabled.value = false
                case .accepted:
                    isContactButtonEnabled.value = true
                case .rejected: // should not be received, defaulting to contact if happens
                    isContactButtonEnabled.value = true
                }
            } else {
                isContactButtonEnabled.value = true
            }
        }
    }
    
    private func openChat() {
        log.debug("open chat called")
        guard let controller = self.controller else {
            log.debug("Unable to open chat view controller is not set")
            return
        }
        
        guard let chatViewModel = self.chatViewModel else {
            log.error("Unable to open chat chat, failed to instantiate chat view model")
            return
        }
        
        GZEChatService.shared.openChat(presenter: controller, viewModel: chatViewModel)
    }
    
    private func observeRequests() {
        self.stopObservingRequests()
        self.requestsObserver = (
            SignalProducer.merge([
                GZEDatesService.shared.sentRequests.producer,
                GZEDatesService.shared.receivedRequests.producer
                ])
                .map{$0.first{[weak self] in
                    guard let this = self else { return false }
                    log.debug("filter called: \(String(describing: $0)) \(String(describing: this.dateRequest))")
                    if this.mode == .request {
                        return $0 == this.dateRequest
                    } else {
                        if let dateReq = this.dateRequest {
                            return $0 == dateReq
                        } else {
                            return $0.recipient.id == this.user.id
                        }
                    }
                    }}
                .skipNil()
                .skipRepeats()
                .startWithValues {[weak self] updatedDateRequest in
                    log.debug("updatedDateRequest: \(String(describing: updatedDateRequest))")
                    self?.dateRequest = updatedDateRequest
            }
        )
    }
    
    private func stopObservingRequests() {
        self.requestsObserver?.dispose()
        self.requestsObserver = nil
    }
    
    private func observeMessages() {
        log.debug("start observing messages")
        var messages: [Signal<String?, NoError>] = []
        
        messages.append(GZEDatesService.shared.message.signal)
        messages.append(GZEDatesService.shared.errorMessage.signal)
        
        self.stopObservingMessages()
        self.messagesObserver = self.error <~ Signal.merge(messages).map{msg -> String? in
            log.debug("Message received: \(String(describing: msg))")
            return msg
        }
    }
    
    private func stopObservingMessages() {
        log.debug("stop observing messages")
        self.messagesObserver?.dispose()
        self.messagesObserver = nil
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
