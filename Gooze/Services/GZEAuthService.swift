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

    // MARK - init
    override init() {
        super.init()
        log.debug("\(self) init")
    }

    func loginStoredUser(completion: ((Bool) -> ())? = nil) {
        log.debug("Attemp to log in stored user")
        if let token = self.token {
            self.loadAuthUser().start {[weak self] event in
                guard let this = self else { completion?(false); return }

                switch event {
                case .value(let user):
                    log.debug("Stored user loaded successfuly")
                    this.login(token: token, user: user)
                    completion?(true)
                case .failed(let error):
                    log.debug("Stored user load failed: \(error.localizedDescription)")
                    completion?(false)
                default: break
                }
            }
        } else {
            log.debug("There's no stored user. Login stored user failed")
            completion?(false)
        }
    }

    func loadAuthUser() -> SignalProducer<GZEUser, GZEError> {
        log.debug("Loading stored user")
        if let token = self.token {
            return self.userRepository.find(byId: token.userId)
        } else {
            log.debug("No stored user found")
            return SignalProducer(error: .repository(error: .AuthRequired))
        }
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
                self.showLogin(presenter: presenter, showExpiredAlert: true, completion: completion)
            }
        }
    }

    func showLogin(presenter: UIViewController, showExpiredAlert: Bool = false, completion: ((Bool) -> ())? = nil) {
        log.debug("Trying to show login modal")
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        if
            let navController = mainStoryboard.instantiateViewController(withIdentifier: "LoginNavController") as? UINavigationController,
            let loginController = navController.viewControllers.first as? GZELoginViewController {

            log.debug("Login controller instanciated. Setting up login view model")
            loginController.viewModel = GZELoginViewModel(self.userRepository)
            loginController.viewModel.dismiss = {
                log.debug("Login modal dismissed")
                presenter.dismiss(animated: true)
                completion?(true)
            }
            presenter.present(navController, animated: true) {
                if showExpiredAlert {
                    GZEAlertService.shared.showBottomAlert(text: "vm.authService.sessionExpired".localized())
                }
            }
        } else {
            log.error("Unable to instantiate LoginNavController")
            GZEAlertService.shared.showBottomAlert(text: GZEError.repository(error: .UnexpectedError).localizedDescription)
        }
    }

    func login(token: GZEAccesToken, user: GZEUser) {
        log.debug("login user to GZEAuthService")
        self.token = token
        self.authUser = user
        GZESocketManager.createSockets()
        GZEDatesService.shared.listenSocketEvents()
    }

    func logout(presenter: UIViewController, completion: ((Bool) -> ())? = nil) {
        log.debug("logout user from GZEAuthService")
        GZESocketManager.destroyAllSockets()
        GZEDatesService.shared.cleanup()
        GZEChatService.shared.cleanup()
        self.userRepository.logout().start()
        self.token = nil
        self.authUser = nil
        self.checkAuth(presenter: presenter, completion: completion)
    }

    // MARK: - private methods


    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
