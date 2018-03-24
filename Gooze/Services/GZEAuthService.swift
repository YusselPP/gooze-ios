//
//  GZEAuthService.swift
//  Gooze
//
//  Created by Yussel on 3/20/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class GZEAuthService: NSObject {
    static let shared = GZEAuthService()


    // MARK: - Instance variables
    var token: GZEAccesToken? {
        set(token) {
            GZEApi.instance.setToken(token)
        }
        get {
            return GZEApi.instance.accessToken
        }
    }

    var authUser: GZEUser?

    var isAuthenticated: Bool {
        if let token = self.token, self.authUser != nil {
            return !token.isExpired
        } else {
            return false
        }
    }

    var userRepository: GZEUserRepositoryProtocol {
        set(userRepo) {
            _userRepository = userRepo
        }
        get {
            if let userRepo = _userRepository {
                return userRepo
            } else {
                return GZEUserApiRepository()
            }
        }
    }
    private var _userRepository: GZEUserRepositoryProtocol?

    private var loadUserAction: Action<Void, GZEUser, GZEError>!

    // MARK - init
    override init() {
        super.init()
        log.debug("\(self) init")

        loadUserAction = Action { [unowned self] in
            return self._loadAuthUser()
        }
    }

    func loginStoredUser(completion: ((Bool) -> ())? = nil) {
        log.debug("Attemp to log in stored user")
        if let token = self.token {
            self.loadStoredUser {[weak self] user in
                if let user = user, let this = self {
                    log.debug("Stored user loaded successfuly")
                    this.login(token: token, user: user)
                    completion?(true)
                } else {
                    log.debug("Stored user load failed")
                    completion?(false)
                }
            }
        } else {
            log.debug("There's no stored user. Login stored user failed")
            completion?(false)
        }
    }

    func loadStoredUser(completion: ((GZEUser?) -> ())? = nil) {
        self.loadUserAction.events.take(first: 1).observeValues {
            log.debug("load user event received: \($0)")
            switch $0 {
            case .value(let user):
                completion?(user)
            default:
                completion?(nil)
            }
        }
        self.loadUserAction.apply().start()
    }

    func checkAuth(presenter: UIViewController, completion: ((Bool) -> ())? = nil) {
        log.debug("checking if session still valid")
        if self.isAuthenticated {
            log.debug("Valid session")
            completion?(true)
        } else {
            log.debug("Invalid sesion")
            if self.token == nil {
                log.debug("Stored token not found")
                self.showLogin(presenter: presenter, completion: completion)
            } else {
                log.debug("Stored token expired")
                presenter.displayMessage(GZEAppConfig.appTitle, "vm.authService.sessionExpired".localized()) {[weak self] in
                    self?.showLogin(presenter: presenter, completion: completion)
                }
            }
        }
    }

    func showLogin(presenter: UIViewController, completion: ((Bool) -> ())? = nil) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        if
            let navController = mainStoryboard.instantiateViewController(withIdentifier: "LoginNavController") as? UINavigationController,
            let loginController = navController.viewControllers.first as? GZELoginViewController {

            loginController.viewModel = GZELoginViewModel(self.userRepository)
            loginController.viewModel.dismiss = {
                presenter.dismiss(animated: true)
                completion?(true)
            }
            presenter.present(navController, animated: true)
        } else {
            log.error("Unable to instantiate LoginNavController")
            presenter.displayMessage("Unexpected error", "Please contact support")
        }
    }

    func login(token: GZEAccesToken, user: GZEUser) {
        log.debug("login user to GZEAuthService")
        self.token = token
        self.authUser = user
        GZESocketManager.createSockets()
    }

    func logout() {
        log.debug("logout user from GZEAuthService")
        GZESocketManager.destroyAllSockets()
        self.userRepository.logout().start()
        self.token = nil
        self.authUser = nil
    }

    // MARK: - private methods

    private func _loadAuthUser() -> SignalProducer<GZEUser, GZEError> {
        log.debug("Loading stored user")
        if let token = self.token {
            return self.userRepository.find(byId: token.userId)
        } else {
            log.debug("No stored user found")
            return SignalProducer(error: .repository(error: .AuthRequired))
        }
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
