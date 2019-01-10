//
//  GZERegisterPayPalViewModel.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 1/5/19.
//  Copyright © 2019 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZERegisterPayPalViewModel {

    let error = MutableProperty<String?>(nil)
    let loading = MutableProperty<Int>(0)
    let title = MutableProperty<String?>(nil)

    let rightBarButtonItem = MutableProperty<UIBarButtonItem?>(nil)

    let (dismiss, dismissObs) = Signal<Void, NoError>.pipe()
    let (next, nextObs) = Signal<Void, NoError>.pipe()
    let (viewShown, viewShownObs) = Signal<Bool, NoError>.pipe()

    let botRightButtonTitle = MutableProperty<String>("Button")
    let botRightButtonHidden =  MutableProperty<Bool>(false)

    var botRightButtonAction: CocoaAction<GZEButton>?

    let descriptionLabelText = MutableProperty<String?>(nil)

    let emailText = MutableProperty<String?>(nil)
    let emailPlaceholder = MutableProperty<String>("")
    let emailConfirmText = MutableProperty<String?>(nil)
    let emailConfirmPlaceholder = MutableProperty<String>("")

    //

    private let payPalAccountTitle = "menu.item.title.registerPayPal".localized().uppercased()
    private let descriptionText = "vm.register.paypal.description".localized()
    private let emailPlaceholderText = "vm.register.paypal.emailPlaceholder".localized()
    private let emailConfirmPlaceholderText = "vm.register.paypal.emailConfirmPlaceholder".localized()
    private let botRightButtonSaveTitle = "vm.register.paypal.botRightButtonSaveTitle".localized()
    private let botRightButtonEditTitle = "vm.register.paypal.botRightButtonEditTitle".localized()

    private let userRepository: GZEUserRepositoryProtocol = GZEUserApiRepository()

    lazy private var saveAction = {
        createSaveAction()
    }()

    init() {
        log.debug("\(self) init")

        self.title.value = self.payPalAccountTitle
        self.descriptionLabelText.value = self.descriptionText
        self.emailPlaceholder.value = self.emailPlaceholderText
        self.emailConfirmPlaceholder.value = self.emailConfirmPlaceholderText
        self.botRightButtonTitle.value = self.botRightButtonSaveTitle.uppercased()

        self.botRightButtonAction = CocoaAction(self.saveAction)

        // Get user paypal email to populate fields
        self.emailText <~ GZEAuthService.shared.authUserProperty.map{$0?.payPalEmail}

        self.saveAction.events.observeValues {[weak self] event in
            log.debug("event received: \(event)")
            guard let this = self else {return}

            switch event {
            case .value: break
            default: this.loading.value -= 1
            }

            switch event {
            case .value(let user):
                GZEAuthService.shared.authUser = user
                this.nextObs.send(value: ())
            case .failed(let err):
                this.onError(err)
            default:
                break
            }
        }
    }

    // Private Methods
    func createSaveAction() -> Action<Void, GZEUser, GZEError> {
        return Action {[weak self] _ in

            guard let this = self else {return SignalProducer(error: .repository(error: .UnexpectedError))}

            this.loading.value += 1

            guard let authUser = GZEAuthService.shared.authUser else {
                return SignalProducer(error: .repository(error: .AuthRequired))
            }

            guard let email = this.emailText.value?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
                return SignalProducer(error: .validation(error: .required(fieldName: GZEUser.Validation.email.fieldName)))
            }

            guard let emailConfirm = this.emailConfirmText.value?.trimmingCharacters(in: .whitespacesAndNewlines), emailConfirm == email else {
                return SignalProducer(error: .message(text: "vm.register.paypal.emailConfirmMismatch", args: []))
            }

            let user = GZEUser(id: authUser.id, username: authUser.username, email: authUser.email)
            user.payPalEmail = email

            return this.userRepository.update(user)
        }
    }


    func onError(_ error: GZEError) {
        self.error.value = error.localizedDescription
    }

    deinit {
        log.debug("\(self) disposed")
    }
}
