//
//  GZELoadingViewModel.swift
//  Gooze
//
//  Created by Yussel on 3/21/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift

class GZELoadingViewModel: NSObject {

    let userRepository: GZEUserRepositoryProtocol

    // MARK - constructor

    init(_ userRepository: GZEUserRepositoryProtocol) {
        self.userRepository = userRepository
        super.init()
        GZEAuthService.shared.userRepository = userRepository
    }

    func loginStoredUser(completion: ((Bool) -> Void)? = nil) {
        GZEAuthService.shared.loginStoredUser(completion: completion)
    }

    func checkAuth(presenter: UIViewController, completion: ((Bool)-> Void)? = nil) {
        GZEAuthService.shared.checkAuth(presenter: presenter, completion: completion)
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
