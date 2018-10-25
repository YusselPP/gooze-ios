//
//  GZESignUpViewModel.swift
//  Gooze
//
//  Created by Yussel on 10/26/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Validator
import Gloss

class GZESignUpViewModel: NSObject {

    let userRepository: GZEUserRepositoryProtocol
    var user: GZEUser? {
        didSet {
            guard let newUser = self.user else {
                return
            }

            username.value = newUser.username
            email.value = newUser.email
            //password.value = newUser.password
            registerCode.value = newUser.registerCode
        }
    }

    var dismiss: (() -> ())?

    let usernameLabelText = GZEUser.Validation.username.fieldName
    let emailLabelText = GZEUser.Validation.email.fieldName
    let passwordLabelText = GZEUser.Validation.password.fieldName
    let registerCodeLabelText = GZEUser.Validation.registerCode.fieldName

    let viewTitle = "vm.signUp.viewTitle".localized()
    let facebookSignUp = "vm.signUp.facebookSignUpButtonTitle".localized()
    let createProfileText = "vm.signUp.createProfileText".localized()
    let skipProfileText = "vm.signUp.skipProfileText".localized()
    let successfulSignUp = "vm.signUp.success".localized()

    let invalidRegisterCodeError = "vm.signUp.invalidRegisterCode".localized()
    let textFieldValidationFailed = "vm.signUp.textField.validation.failed".localized()

    var isRegisterCodeRequired: Bool = false

    // basic sign up
    let username = MutableProperty<String?>(nil)
    let email = MutableProperty<String?>(nil)
    let password = MutableProperty<String?>(nil)
    let registerCode = MutableProperty<String?>(nil)
    let termsAccepted = MutableProperty<Bool>(false)
    let facebookId = MutableProperty<String?>(nil)

    enum validationRule {
        case username
        case email
        case password
        case registerCode

        var stringRules: ValidationRuleSet<String>? {
            switch self {
            case .username:
                return GZEUser.Validation.username.stringRule()
            case .email:
                return GZEUser.Validation.email.stringRule()
            case .password:
                return GZEUser.Validation.password.stringRule()
            case .registerCode:
                return GZEUser.Validation.registerCode.stringRule()
            }
        }
    }
    
    var updateProfileViewModel: GZEUpdateProfileViewModel? {
        if let user = self.user {
            let vm = GZEUpdateProfileViewModel(self.userRepository, user: user)
            vm.dismiss = self.dismiss
            return vm
        } else {
            return nil
        }
    }

    var usernameExistsAction: Action<Void, Bool, GZEError>!
    var emailExistsAction: Action<Void, Bool, GZEError>!
    var facebookExistsAction: Action<Void, Bool, GZEError>!
    var signupAction: Action<Void, GZEUser, GZEError>!
    lazy var isValidRegisterCodeAction: Action<Void, Bool, GZEError> = {
        return self.createIsValidRegisterCodeAction()
    }()
    

    init(_ userRepository: GZEUserRepositoryProtocol) {
        self.userRepository = userRepository

        super.init()

        log.debug("\(self) init")

        usernameExistsAction = Action { [unowned self] in
            return self.onUsernameExistsAction()
        }
        emailExistsAction = Action { [unowned self] in
            return self.onEmailExistsAction()
        }
        facebookExistsAction = Action { [unowned self] in
            return self.onFacebookExistsAction()
        }
        signupAction = Action { [unowned self] in
            return self.onSignupAction()
        }

        signupAction.values
            .observeValues {[weak self] user in
                log.debug("user updated: \(user.toJSON() as  Any)")
                GZEAuthService.shared.authUser = user
                self?.user = user
            }
    }


    private func onUsernameExistsAction() -> SignalProducer<Bool, GZEError> {
        guard let username = username.value else {
            return SignalProducer(error: .validation(error: .required(fieldName: GZEUser.Validation.username.fieldName)))
        }

        return self.userRepository.usernameExists(username)
    }

    private func onEmailExistsAction() -> SignalProducer<Bool, GZEError> {
        guard let email = email.value else {
            return SignalProducer(error: .validation(error: .required(fieldName: GZEUser.Validation.email.fieldName)))
        }

        return self.userRepository.emailExists(email)
    }

    private func onFacebookExistsAction() -> SignalProducer<Bool, GZEError> {
        guard let facebookId = facebookId.value else {
            return SignalProducer(error: .validation(error: .required(fieldName: "facebookId")))
        }

        return self.userRepository.facebookExist(facebookId)
    }

    private func createIsValidRegisterCodeAction() -> Action<Void, Bool, GZEError> {
        return Action {[weak self] in
            guard let this = self else {
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }

            guard let registerCode = this.registerCode.value else {
                return SignalProducer(error: .validation(error: .required(fieldName: "Code")))
            }

            return this.userRepository.isValidRegisterCode(registerCode)
        }
    }

    private func onSignupAction() -> SignalProducer<GZEUser, GZEError> {

        guard let aUsername = username.value else {
            return SignalProducer(error: .validation(error: .required(fieldName: GZEUser.Validation.username.fieldName)))
        }

        guard let aEmail = email.value else {
            return SignalProducer(error: .validation(error: .required(fieldName: GZEUser.Validation.email.fieldName)))
        }

        guard let aPassword = password.value else {
            return SignalProducer(error: .validation(error: .required(fieldName: GZEUser.Validation.password.fieldName)))
        }

        var userJSON: JSON = JSON()
        if let facebookId = facebookId.value {
            userJSON["facebookId"] = facebookId
        }
        if let registerCode = registerCode.value {
            userJSON["registerCode"] = registerCode
        }

        return self.userRepository.signUp(username: aUsername, email: aEmail, password: aPassword, userJSON: userJSON)
    }
 

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
