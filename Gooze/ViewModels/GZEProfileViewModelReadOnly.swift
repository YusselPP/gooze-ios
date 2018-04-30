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
import SwiftOverlays

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
        guard let dateRequestId = self.dateRequest?.id else {
            log.error("Unable to open the chat, found nil date request")
            error.value = "service.chat.invalidChatId".localized()
            return nil
        }
        
        guard let chat = self.dateRequest?.chat else {
            log.error("Unable to open the chat, found nil chat on date request")
            error.value = "service.chat.invalidChatId".localized()
            return nil
        }
        
        var chatMode: GZEChatViewMode
        if self.mode == .request {
            chatMode = .gooze
        } else {
            chatMode = .client
        }
        
        return GZEChatViewModelDates(chat: chat, dateRequestId: dateRequestId, mode: chatMode, username: self.user.username)
    }
    weak var controller: UIViewController?
    
    
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
    // End GZEProfileViewModel protocol
    
    
    let user: GZEUser
    
    let contactButtonTitle = "vm.profile.contactTitle".localized().uppercased()
    let acceptRequestButtonTitle = "vm.profile.acceptRequestTitle".localized().uppercased()
    let acceptedRequestButtonTitle = "vm.profile.acceptedRequestButtonTitle".localized().uppercased()
    let rejectedRequestButtonTitle = "vm.profile.rejectedRequestButtonTitle".localized().uppercased()
    let sentRequestButtonTitle = "vm.profile.sentRequestButtonTitle".localized().uppercased()
    let endedRequestButtonTitle = "vm.profile.endedRequestButtonTitle".localized().uppercased()
    let isContactButtonEnabled = MutableProperty<Bool>(false)

    var messagesObserver: Disposable?
    var requestsObserver: Disposable?
    var socketEventsObserver: Disposable?

    // MARK - init
    init(user: GZEUser, dateRequestId: String? = nil) {
        self.user = user
        super.init()
        log.debug("\(self) init")

        self.getUpdatedRequest(dateRequestId)

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
                    case .rejected, .ended:
                        return SignalProducer.empty
                    }
                } else {
                    return SignalProducer.empty
                }
                
            } else {
                if let dateRequest = this.dateRequest {
                    switch dateRequest.status {
                    case .sent,
                         .received,
                         .rejected,
                         .ended:
                        break
                    case .accepted:
                        this.openChat()
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
        case .value(let dateRequest):
            self.dateRequest = dateRequest
            switch self.mode {
            case .request: self.openChat()
            default: break
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
                case .ended:
                    self.actionButtonTitle.value = self.endedRequestButtonTitle
                }
            } else {
                self.actionButtonTitle.value = ""
            }
        } else {
            if let dateRequest = self.dateRequest {
                switch dateRequest.status {
                case .sent,
                     .received:
                    self.actionButtonTitle.value = self.sentRequestButtonTitle
                case .accepted:
                    self.actionButtonTitle.value = self.acceptedRequestButtonTitle
                case .rejected:
                    self.actionButtonTitle.value = self.rejectedRequestButtonTitle
                case .ended:
                    self.actionButtonTitle.value = self.endedRequestButtonTitle
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
                case .rejected, .ended:
                    isContactButtonEnabled.value = false
                }
            } else {
                isContactButtonEnabled.value = false
            }
        } else {
            if let dateRequest = self.dateRequest {
                switch dateRequest.status {
                case .sent,
                     .received,
                     .rejected,
                     .ended:
                    isContactButtonEnabled.value = false
                case .accepted:
                    isContactButtonEnabled.value = true
                }
            } else {
                isContactButtonEnabled.value = true
            }
        }
    }
    
    private func openChat() {
        log.debug("open chat called")
        SwiftOverlays.showBlockingWaitOverlay()

        guard let navcontroller = self.controller?.navigationController else {
            log.debug("Unable to open chat view navcontroller is not set")
            SwiftOverlays.removeAllBlockingOverlays()
            return
        }

        navcontroller.popViewController(animated: true)

        guard let controller = navcontroller.topViewController else {
            log.debug("Unable to open chat view controller is not set")
            SwiftOverlays.removeAllBlockingOverlays()
            return
        }
        
        guard let chatViewModel = self.chatViewModel else {
            log.error("Unable to open chat chat, failed to instantiate chat view model")
            SwiftOverlays.removeAllBlockingOverlays()
            return
        }

        GZEChatService.shared.openChat(presenter: controller, viewModel: chatViewModel) {
            SwiftOverlays.removeAllBlockingOverlays()
        }
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
                this.getUpdatedRequest(this.dateRequest?.id)
        }
    }
    
    private func stopObservingSocketEvents() {
        log.debug("stop observing SocketEvents")
        self.socketEventsObserver?.dispose()
        self.socketEventsObserver = nil
    }

    private func getUpdatedRequest(_ dateRequestId: String?) {
        if let dateRequestId = dateRequestId {
            SwiftOverlays.showBlockingWaitOverlay()

            GZEDatesService.shared.find(byId: dateRequestId)
                .start{[weak self] event in
                    log.debug("find request event received: \(event)")

                    SwiftOverlays.removeAllBlockingOverlays()

                    guard let this = self else {return}
                    switch event {
                    case .value(let dateRequest):
                        this.dateRequest = dateRequest
                    case .failed(let error):
                        log.error(error.localizedDescription)
                    default: break
                    }
            }
        }
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
