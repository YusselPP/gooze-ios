//
//  GZEProfileViewModelReadOnly.swift
//  Gooze
//
//  Created by Yussel on 3/5/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
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
    let dateRequest: MutableProperty<GZEDateRequest?>

    var acceptRequestAction: Action<Void, GZEDateRequest, GZEError>!

    var bottomButtonAction: CocoaAction<GZEButton>?

    let loading = MutableProperty<Bool>(false)
    let error = MutableProperty<String?>(nil)

    let actionButtonIsHidden = MutableProperty<Bool>(false)
    let actionButtonTitle = MutableProperty<String>("")

    weak var controller: UIViewController?

    let (didLoad, didLoadObs) = Signal<Void, NoError>.pipe()

    func startObservers() {
        self.appearObs.send(value: ())

        self.observeRequests()
        self.observeSocketEvents()

        self.dateRequest.producer
            .take(until: self.disappearSignal)
            .on(disposed: {log.debug("dateRequest observer disposed")})
            .startWithValues{[weak self] dateRequest in
                log.debug("dateRequest didSet: \(String(describing: dateRequest))")
                guard let this = self else {return}

                if let dateRequest = dateRequest {
                    GZEDatesService.shared.activeRequest = MutableProperty(dateRequest)
                } else {
                    GZEDatesService.shared.activeRequest = nil
                }

                this.setMode()
            }
    }
    
    func stopObservers() {
        self.disappearObs.send(value: ())

        self.stopObservingSocketEvents()
        self.stopObservingRequests()

        if let activeRequest = GZEDatesService.shared.activeRequest {
            activeRequest.signal
                .take(until: self.appearSignal)
                .observeValues {[weak self] dateRequest in
                    log.debug("dateRequest didSet: \(String(describing: dateRequest))")
                    guard let this = self else {return}
                    this.dateRequest.value = dateRequest
                }
        }
    }
    // End GZEProfileViewModel protocol
    
    
    let user: GZEUser
    
    let contactButtonTitle = "vm.profile.contactTitle".localized().uppercased()
    let acceptRequestButtonTitle = "vm.profile.acceptRequestTitle".localized().uppercased()
    let acceptedRequestButtonTitle = "vm.profile.acceptedRequestButtonTitle".localized().uppercased()
    let rejectedRequestButtonTitle = "vm.profile.rejectedRequestButtonTitle".localized().uppercased()
    let sentRequestButtonTitle = "vm.profile.sentRequestButtonTitle".localized().uppercased()
    let endedRequestButtonTitle = "vm.profile.endedRequestButtonTitle".localized().uppercased()

    let addPayPalAccountRequest = "vm.profile.addPayPalAccountRequest".localized()
    let addPayPalAccountAnswerAdd = "vm.profile.addPayPalAccountAnswerAdd".localized()
    let addPayPalAccountAnswerLater = "vm.profile.addPayPalAccountAnswerLater".localized()

    let addPaymentMethodRequest = "vm.profile.addPaymentMethodRequest".localized()
    let addPaymentMethodAnswerAdd = "vm.profile.addPaymentMethodAnswerAdd".localized()
    let addPaymentMethodAnswerLater = "vm.profile.addPaymentMethodAnswerLater".localized()

    let completeProfileRequest = "vm.profile.completeProfileRequest".localized()
    let completeProfileRequestYes = "vm.profile.completeProfileRequestYes".localized()
    let completeProfileRequestNo = "vm.profile.completeProfileRequestNo".localized()

    let isContactButtonEnabled = MutableProperty<Bool>(false)

    var messagesObserver: Disposable?
    var requestsObserver: Disposable?
    var socketEventsObserver: Disposable?
    var (disappearSignal, disappearObs) = Signal<Void, NoError>.pipe()
    var (appearSignal, appearObs) = Signal<Void, NoError>.pipe()

    var chatViewModel: GZEChatViewModel? {
        log.debug("chatViewModel called")
        guard let daRequestProperty = GZEDatesService.shared.activeRequest else {
            log.error("Unable to open the chat, found nil active date request")
            error.value = "service.chat.invalidChatId".localized()
            return nil
        }

        guard let chat = self.dateRequest.value?.chat else {
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

        return GZEChatViewModelDates(chat: chat, dateRequest: daRequestProperty, mode: chatMode, username: self.user.username)
    }

    var registerPayPalViewModel: GZERegisterPayPalViewModel {
        return GZERegisterPayPalViewModel()
    }

    var paymentsViewModel: GZEPaymentMethodsViewModel {
        return GZEPaymentMethodsViewModelAdded()
    }

    // MARK - init
    init(user: GZEUser, dateRequest: MutableProperty<GZEDateRequest?>) {
        self.user = user
        self.dateRequest = dateRequest
        super.init()
        log.debug("\(self) init")

        self.getUpdatedRequest(dateRequest.value?.id)

        let acceptRequestAction = self.createAcceptRequestAction()
        acceptRequestAction.events.observeValues {[weak self] in
            self?.onAcceptRequestAction($0)
        }

        self.bottomButtonAction = CocoaAction(acceptRequestAction) { [weak self] _ in
            self?.loading.value = true
        }
    }
    
    private func createAcceptRequestAction() -> Action<Void, GZEDateRequest, GZEError> {
        return Action(enabledIf: isContactButtonEnabled) {[weak self] in
            guard let this = self else {
                log.error("self disposed before used");
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }
            
            if this.mode == .request {
                if let dateRequest = this.dateRequest.value {
                    switch dateRequest.status {
                    case .sent,
                         .received:
                        return GZEDatesService.shared.acceptDateRequest(withId: this.dateRequest.value?.id)
                    case .accepted, .onDate:
                        this.openChat()
                        return SignalProducer.empty
                    case .rejected, .ended:
                        return SignalProducer.empty
                    }
                } else {
                    return SignalProducer.empty
                }
                
            } else {
                if let dateRequest = this.dateRequest.value {
                    switch dateRequest.status {
                    case .sent,
                         .received,
                         .rejected,
                         .ended:
                        break
                    case .accepted, .onDate:
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
        self.loading.value = false

        switch event {
        case .value(let dateRequest):
            GZEDatesService.shared.upsert(dateRequest: dateRequest)
            self.dateRequest.value = dateRequest

            switch self.mode {
            case .request:
                self.openChat()
            case .contact:
                self.error.value = "service.dates.requestSuccessfullySent".localized()
            }
        case .failed(let error):
            onError(error)
        default: break
        }
    }
    
    private func onError(_ error: GZEError) {
        switch error {
        case .datesSocket(let datesError):
            if datesError == .payPalAccountRequired {
                GZEAlertService.shared.showConfirmDialog(
                    title: error.localizedDescription,
                    message: addPayPalAccountRequest,
                    buttonTitles: [addPayPalAccountAnswerAdd],
                    cancelButtonTitle: addPayPalAccountAnswerLater,
                    actionHandler: {[weak self] (_, _, _) in
                        log.debug("Add pressed")
                        self?.openRegisterPayPalView()
                    },
                    cancelHandler: { _ in
                        log.debug("Cancel pressed")
                }
                )
                return
            }
            if datesError == .paymentMethodRequired {
                GZEAlertService.shared.showConfirmDialog(
                    title: error.localizedDescription,
                    message: addPaymentMethodRequest,
                    buttonTitles: [addPaymentMethodAnswerAdd],
                    cancelButtonTitle: addPaymentMethodAnswerLater,
                    actionHandler: {[weak self] (_, _, _) in
                        log.debug("Add pressed")
                        self?.openAddPaymentMethodsView()
                    },
                    cancelHandler: { _ in
                        log.debug("Cancel pressed")
                    }
                )
                return
            }
            if datesError == .incompleteProfile {
                GZEAlertService.shared.showConfirmDialog(
                    title: error.localizedDescription,
                    message: completeProfileRequest,
                    buttonTitles: [completeProfileRequestYes],
                    cancelButtonTitle: completeProfileRequestNo,
                    actionHandler: {[weak self] (_, _, _) in
                        log.debug("Yes pressed")
                        guard let this = self else {return}
                        this.openMyProfileView()
                    },
                    cancelHandler: { _ in
                        log.debug("No pressed")
                    }
                )
                return
            }
        default:
            break
        }

        self.error.value = error.localizedDescription
    }
    
    private func setMode() {
        setActionButtonTitle()
        setActionButtonState()
    }
    
    private func setActionButtonTitle() {
        log.debug("set action button title called")
        if mode == .request {
            if let dateRequest = self.dateRequest.value {
                switch dateRequest.status {
                case .sent,
                     .received:
                    self.actionButtonTitle.value = self.acceptRequestButtonTitle
                case .accepted, .onDate:
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
            if let dateRequest = dateRequest.value {
                switch dateRequest.status {
                case .sent,
                     .received:
                    self.actionButtonTitle.value = self.sentRequestButtonTitle
                case .accepted, .onDate:
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
            if let dateRequest = self.dateRequest.value {
                switch dateRequest.status {
                case .sent,
                     .received,
                     .accepted,
                     .onDate:
                    isContactButtonEnabled.value = true
                case .rejected, .ended:
                    isContactButtonEnabled.value = false
                }
            } else {
                isContactButtonEnabled.value = false
            }
        } else {
            if let dateRequest = self.dateRequest.value {
                switch dateRequest.status {
                case .sent,
                     .received,
                     .rejected,
                     .ended:
                    isContactButtonEnabled.value = false
                case .accepted, .onDate:
                    isContactButtonEnabled.value = true
                }
            } else {
                isContactButtonEnabled.value = true
            }
        }
    }

    private func openChat() {
        log.debug("open chat called")

        guard
            let controller = self.controller as? GZEProfilePageViewController,
            let chatViewModel = self.chatViewModel
        else {
            log.error("Unable to open chat view GZEProfilePageViewController is not set")
            return
        }

        controller.performSegue(withIdentifier: controller.segueToChat, sender: chatViewModel)
    }

    private func openRegisterPayPalView() {
        log.debug("openRegisterPayPalView called")

        guard
            let controller = self.controller as? GZEProfilePageViewController
            else {
                log.error("Unable to payment view GZEProfilePageViewController is not set")
                return
        }

        controller.performSegue(withIdentifier: controller.segueToRegisterPayPal, sender: self.registerPayPalViewModel)
    }

    private func openAddPaymentMethodsView() {
        log.debug("openAddPaymentMethodsView called")

        guard
            let controller = self.controller as? GZEProfilePageViewController
        else {
                log.error("Unable to payment view GZEProfilePageViewController is not set")
                return
        }

        controller.performSegue(withIdentifier: controller.segueToPayments, sender: self.paymentsViewModel)
    }

    private func openMyProfileView() {
        log.debug("openMyProfileView called")

        guard
            let navController = self.controller?.navigationController,
            let myProfileController = self.controller?.storyboard?.instantiateViewController(withIdentifier: "GZEProfilePageViewController") as? GZEProfilePageViewController
        else {
            log.error("Unable to open my profile view, failed to instantiate GZEProfilePageViewController")
            return
        }

        guard let user = GZEAuthService.shared.authUser else {
            log.error("Unable to open my profile view, Auth user not found")
            return
        }

        myProfileController.profileVm = GZEProfileUserInfoViewModelMe(user)
        myProfileController.ratingsVm = GZERatingsViewModelMe(user)
        myProfileController.galleryVm = GZEGalleryViewModelMe(user)

        navController.pushViewController(myProfileController, animated: true)
    }

    private func observeRequests() {
        self.stopObservingRequests()
        self.requestsObserver = (
            Signal.merge([
                GZEDatesService.shared.lastReceivedRequest.signal,
                GZEDatesService.shared.lastSentRequest.signal
                ])
                .skipNil()
                .filter{[weak self] in
                    guard let this = self else { return false }
                    log.debug("filter called: \(String(describing: $0)) \(String(describing: this.dateRequest))")
                    return $0 == this.dateRequest.value
                }
                .observeValues {[weak self] updatedDateRequest in
                    log.debug("updatedDateRequest: \(String(describing: updatedDateRequest))")
                    self?.dateRequest.value = updatedDateRequest
            }
        )
    }
    
    private func stopObservingRequests() {
        self.requestsObserver?.dispose()
        self.requestsObserver = nil
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
                this.getUpdatedRequest(this.dateRequest.value?.id)
        }
    }
    
    private func stopObservingSocketEvents() {
        log.debug("stop observing SocketEvents")
        self.socketEventsObserver?.dispose()
        self.socketEventsObserver = nil
    }

    private func getUpdatedRequest(_ dateRequestId: String?) {
        if let dateRequestId = dateRequestId {
            let blocker = SwiftOverlays.showBlockingWaitOverlay()

            GZEDatesService.shared.find(byId: dateRequestId)
                .start{[weak self] event in
                    log.debug("find request event received: \(event)")

                    blocker.removeFromSuperview()

                    guard let this = self else {return}
                    switch event {
                    case .value(let dateRequest):
                        this.dateRequest.value = dateRequest
                    case .failed(let error):
                        log.error(error.localizedDescription)
                    default: break
                    }
            }
        }
    }

    // MARK: - Deinitializers
    deinit {
        GZEDatesService.shared.activeRequest = nil
        log.debug("\(self) disposed")
    }
}
