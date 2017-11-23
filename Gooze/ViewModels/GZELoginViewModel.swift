//
//  GZELoginViewModel.swift
//  Gooze
//
//  Created by Yussel on 10/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift

class GZELoginViewModel {

    let viewTitle = "vm.login.loginViewTitle".localized()
    let loginButtonTitle = "vm.login.loginButtonTitle".localized()
    let signUpButtonTitle = "vm.login.signUpButtonTitle".localized()
    let forgotPasswordButtonTitle = "vm.login.forgotPassword".localized()
    let displayOkTitle = "vm.login.alertOkButtonTitle".localized()

    let userRepository: GZEUserRepositoryProtocol

    let email = MutableProperty<String?>("")
    let password = MutableProperty<String?>("")

    var loginAction: Action<Void, GZEAccesToken, GZEError> {
        if let loginAction = _loginAction {
            return loginAction
        }
        _loginAction = createLoginAction()
        return _loginAction!
    }

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
        return GZESignUpViewModel(userRepository)
    }

    func getRegisterCodeViewModel() -> GZERegisterCodeViewModel {
        return GZERegisterCodeViewModel(userRepository)
    }

    func getChooseModeViewModel() -> GZEChooseModeViewModel {
        return GZEChooseModeViewModel(userRepository)
    }

    private func createLoginAction() -> Action<Void, GZEAccesToken, GZEError> {
        log.debug("Creating login action")
        return Action<Void, GZEAccesToken, GZEError>{[weak self] in

            // return SignalProducer<GZEAccesToken, GZEError>(value: GZEAccesToken(id: "", ttl: 0, userId: "", created: Date()))
            guard let strongSelf = self else { return SignalProducer.empty }
            return strongSelf.userRepository.login(strongSelf.email.value, strongSelf.password.value)
        }
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }

}
