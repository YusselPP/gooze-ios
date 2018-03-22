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
    var loadUserAction: Action<Void, GZEUser, GZEError>!

    // MARK - constructor

    init(_ userRepository: GZEUserRepositoryProtocol) {
        self.userRepository = userRepository
        super.init()

        loadUserAction = Action { [unowned self] in
            return self.loadAuthUser()
        }

        loadUserAction.events.observeValues {
            switch $0 {
            case .value(let user): GZEAuthService.shared.login(user: user)
            case .completed: break
            default: break
            }
        }
    }

    func checkAuth(_ vc: UIViewController) {
        if GZEAuthService.shared.isAuthenticated {
            loadUserAction.apply().start()
        } else {
            showLogin(vc)
        }
    }

    func loadAuthUser() -> SignalProducer<GZEUser, GZEError> {
        if let token = GZEAuthService.shared.token {
            return userRepository.find(byId: token.userId)
        } else {
            log.debug("No auth user found")
            return SignalProducer.init(error: .repository(error: .AuthRequired))
        }
    }

    func login(_ vc: UIViewController) {

    }

    func showLogin(_ vc: UIViewController) {
        
    }
}
