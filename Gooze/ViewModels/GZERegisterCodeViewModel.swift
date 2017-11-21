//
//  GZERegisterCodeViewModel.swift
//  Gooze
//
//  Created by Yussel on 11/18/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation

class GZERegisterCodeViewModel {

    let userRepository: GZEUserRepositoryProtocol

    init(_ userRepository: GZEUserRepositoryProtocol) {

        self.userRepository = userRepository

        log.debug("\(self) init")
    }

    func getSignUpViewModel() -> GZESignUpViewModel {
        return GZESignUpViewModel(userRepository)
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
