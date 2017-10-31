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
import ReactiveCocoa

class GZELoginViewModel {

    let viewTitle = "Login".localized()
    let loginButtonTitle = "Login".localized()
    let signUpButtonTitle = "Sign up".localized()
    let displayOkTitle = "Ok".localized()

    let userRepository: GZEUserRepositoryProtocol


    let email = MutableProperty<String?>("")
    let password = MutableProperty<String?>("")

    var loginAction: Action<Void, GZEAccesToken, GZERepositoryError> {
        if let loginAction = _loginAction {
            return loginAction
        }
        _loginAction = createLoginAction()
        return _loginAction!
    }

    private var _loginAction: Action<Void, GZEAccesToken, GZERepositoryError>?



    // Mark: Initializers
    init(_ userRepository: GZEUserRepositoryProtocol) {
        self.userRepository = userRepository
        log.debug("\(self) init")
    }


    func getSearchGoozeViewModel() -> GZESearchGoozeViewModel {
        return GZESearchGoozeViewModel()
    }

    func getSignUpViewModel() -> GZESignUpViewModel {
        return GZESignUpViewModel(userRepository)
    }

    private func createLoginAction() -> Action<Void, GZEAccesToken, GZERepositoryError> {
        log.debug("Creating login action")
        return Action<Void, GZEAccesToken, GZERepositoryError>{[weak self] in
            guard let strongSelf = self else { return SignalProducer.empty }
            return strongSelf.userRepository.login(strongSelf.email.value, strongSelf.password.value)
        }
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }

}
