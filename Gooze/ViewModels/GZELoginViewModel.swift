//
//  GZELoginViewModel.swift
//  Gooze
//
//  Created by Yussel on 10/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class GZELoginViewModel {

    let viewTitle = "vm.login.loginViewTitle".localized()
    let loginButtonTitle = "vm.login.loginButtonTitle".localized()
    let signUpButtonTitle = "vm.login.signUpButtonTitle".localized()
    let forgotPasswordButtonTitle = "vm.login.forgotPassword".localized()
    let resetEmailSent = "vm.login.resetEmailSent".localized()
    let emailNotFound = "vm.login.emailNotfound".localized()

    let usernameLabel = "vm.login.usernameLabel".localized()
    let passwordLabel = "vm.login.passwordLabel".localized()
    let resetPasswordLabel = "vm.login.resetPasswordLabel".localized()

    let displayOkTitle = "vm.login.alertOkButtonTitle".localized()

    let fbLoginTitle: NSMutableAttributedString

    var isRegisterCodeRequired: Bool = false

    let userRepository: GZEUserRepositoryProtocol

    let email = MutableProperty<String?>("")
    let password = MutableProperty<String?>("")
    let resetPassword = MutableProperty<String?>("")
    let facebookToken = MutableProperty<String?>(nil)

    var dismiss: (() -> ())?

    var loginAction: Action<Void, GZEAccesToken, GZEError> {
        if let loginAction = _loginAction {
            return loginAction
        }
        _loginAction = createLoginAction()
        return _loginAction!
    }

    lazy var facebookLoginAction: Action<Void, GZEAccesToken, GZEError> = {
        return self.createFacebookLoginAction()
    }()

    lazy var resetPasswordAction: Action<Void, Void, GZEError> = {
        return self.createResetPasswordAction()
    }()



    private var _loginAction: Action<Void, GZEAccesToken, GZEError>?

    // Mark: Initializers
    init(_ userRepository: GZEUserRepositoryProtocol) {
        let fbTitle = "\u{f09a}  " + "vm.login.facebookLogin".localized()
        fbLoginTitle = NSMutableAttributedString(string: fbTitle)
        fbLoginTitle.setAttributes(
            [NSAttributedString.Key.font: GZEConstants.Font.mainAwesome],
            range: NSRange.init(location: 0, length: 1)
        )
        fbLoginTitle.setAttributes(
            [NSAttributedString.Key.font: GZEConstants.Font.main],
            range: NSRange.init(location: 1, length: fbTitle.count - 2)
        )
        self.userRepository = userRepository
        log.debug("\(self) init")
    }


    func getSearchGoozeViewModel() -> GZESearchGoozeViewModel {
        return GZESearchGoozeViewModel(userRepository)
    }

    func getSignUpViewModel() -> GZESignUpViewModel {
        let viewModel = GZESignUpViewModel(userRepository)
        viewModel.dismiss = dismiss
        viewModel.isRegisterCodeRequired = isRegisterCodeRequired

        return viewModel
    }

    func getChooseModeViewModel() -> GZEChooseModeViewModel {
        return GZEChooseModeViewModel(userRepository)
    }

    private func createLoginAction() -> Action<Void, GZEAccesToken, GZEError> {
        log.debug("Creating login action")
        return Action<Void, GZEAccesToken, GZEError>{[weak self] in

            // return SignalProducer<GZEAccesToken, GZEError>(value: GZEAccesToken(id: "", ttl: 0, userId: "", created: Date()))
            guard let strongSelf = self else {
                log.error("self disposed")
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }
            return strongSelf.userRepository.login(strongSelf.email.value, strongSelf.password.value)
        }
    }

    private func createFacebookLoginAction() -> Action<Void, GZEAccesToken, GZEError> {
        log.debug("Creating login action")
        return Action{[weak self] in

            guard let this = self else {
                log.error("self disposed")
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }

            guard let token = this.facebookToken.value else {
                log.error("received nil facebook token")
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }

            return this.userRepository.facebookLogin(token)
        }
    }

    private func createResetPasswordAction() -> Action<Void, Void, GZEError> {
        log.debug("Creating login action")
        return Action{[weak self] in

            guard let this = self else {
                log.error("self disposed")
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }

            guard let email = this.resetPassword.value, !email.isEmpty else {
                return SignalProducer(error: .validation(error: .required(fieldName: GZEUser.Validation.email.fieldName)))
            }

            return this.userRepository.resetPassword(email)
        }
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }

}
