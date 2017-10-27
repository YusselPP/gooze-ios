//
//  GZESignUpViewModel.swift
//  Gooze
//
//  Created by Yussel on 10/26/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift

class GZESignUpViewModel {

    let userRepository: GZEUserRepositoryProtocol
    let user = GZEUser()

    let username = MutableProperty<String?>("")
    let email = MutableProperty<String?>("")
    let password = MutableProperty<String?>("")

    init(_ userRepository: GZEUserRepositoryProtocol) {
        self.userRepository = userRepository
        log.debug("\(self) init")
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
