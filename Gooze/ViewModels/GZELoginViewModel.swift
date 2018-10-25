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

    let usernameLabel = "vm.login.usernameLabel".localized()
    let passwordLabel = "vm.login.passwordLabel".localized()

    let displayOkTitle = "vm.login.alertOkButtonTitle".localized()

    var isRegisterCodeRequired: Bool = false

    let userRepository: GZEUserRepositoryProtocol

    let email = MutableProperty<String?>("")
    let password = MutableProperty<String?>("")
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


    private var _loginAction: Action<Void, GZEAccesToken, GZEError>?

    // Mark: Initializers
    init(_ userRepository: GZEUserRepositoryProtocol) {
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

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }

}
