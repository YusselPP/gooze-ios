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
    enum TestError: Error {
        case error1
    }

    var userRepository = GZEUserApiRepository()
    var user: GZEUser?

    var i = 0
    let username: MutableProperty<String?> = MutableProperty("")
    let password: MutableProperty<String?> = MutableProperty("")
    let errorMessage: MutableProperty<String?> = MutableProperty("")

    lazy var postAction: Action<Void, GZEUser, GZERepositoryError> = Action<Void, GZEUser, GZERepositoryError>(enabledIf: MutableProperty(true)) {
        return self.userRepository.login(self.username.value!, self.password.value!)
    }

    init() {
        postAction.errors.observeValues { err in
            log.error(err)
            self.errorMessage.value = err.localizedDescription
        }
        postAction.values.observeValues({ user in
            log.debug("User logged succesfully: " + user.description)
            self.user = user
        })
    }
}
