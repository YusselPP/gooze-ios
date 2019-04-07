//
//  GZELoginViewController.swift
//  Gooze
//
//  Created by Yussel on 10/21/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import SwiftOverlays
import Gloss

class GZELoginViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    let registerCodeSegueId = "registerCodeSegue"

    enum Scene {
        case loadingTransition
        case login
        case username
        case password
        case resetPassword
    }

    var scene = Scene.loadingTransition {
        didSet {
            handleSceneChanged()
        }
    }

    var viewModel: GZELoginViewModel!

    var loginAction: CocoaAction<UIBarButtonItem>!
    var facebookLoginAction: CocoaAction<UIBarButtonItem>!
    var resetPasswordAction: CocoaAction<UIBarButtonItem>!

    let usernameLabel = UILabel()
    let passwordLabel = UILabel()
    let resetPasswordLabel = UILabel()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let resetPasswordTextField = UITextField()
    let loginButton = UIButton()
    let signUpButton = UIButton()
    let forgotPasswordButton = UIButton()

    var backButton = GZEBackUIBarButtonItem()
    var nextButton = GZENextUIBarButtonItem()

    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoContainer: UIView!
    @IBOutlet weak var doubleCtrlView: GZEDoubleCtrlView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomButton: GZEButton!

    var topLogoConstraint: NSLayoutConstraint!
    var centerLogoConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("\(self) init")

        setupInterfaceObjects()
        setupBindings()

        handleSceneChanged()

        navigationController?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboarNotifications(
            observer: self,
            willShowSelector: #selector(keyboardWillShow(notification:)),
            willHideSelector: #selector(keyboardWillHide(notification:))
        )
        if scene != .loadingTransition {
            scene = .login
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        log.debug("view did appear")
        if scene == .loadingTransition {
            DispatchQueue.main.async {
                log.debug("animating transistion")
                UIView.animate(withDuration: 0.5, animations: {
                    [weak self] in

                    self?.centerLogoConstraint.isActive = false
                    self?.topLogoConstraint.isActive = true
                    self?.view.layoutIfNeeded()
                }) {[weak self] _ in
                    log.debug("animation end")
                    self?.scene = .login
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications(observer: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupInterfaceObjects() {
        navigationItem.setLeftBarButton(backButton, animated: false)
        navigationItem.setRightBarButton(nextButton, animated: false)
        backButton.onButtonTapped = ptr(self, GZELoginViewController.backButtonTapped)
        nextButton.onButtonTapped = ptr(self, GZELoginViewController.nextButtonTapped)

        // Titles
        usernameLabel.text = viewModel.usernameLabel.uppercased()
        passwordLabel.text = viewModel.passwordLabel.uppercased()
        resetPasswordLabel.text = viewModel.resetPasswordLabel.uppercased()
        loginButton.setTitle(viewModel.loginButtonTitle.uppercased(), for: .normal)
        signUpButton.setTitle(viewModel.signUpButtonTitle.uppercased(), for: .normal)
        forgotPasswordButton.setTitle(viewModel.forgotPasswordButtonTitle, for: .normal)

        bottomButton.setGrayFormat()

        bottomButton.widthConstraint.constant = 220

        emailTextField.keyboardType = .emailAddress
        emailTextField.returnKeyType = .next
        emailTextField.delegate = self
        emailTextField.autocapitalizationType = .none

        passwordTextField.returnKeyType = .send
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self

        resetPasswordTextField.keyboardType = .emailAddress
        resetPasswordTextField.returnKeyType = .next
        resetPasswordTextField.delegate = self
        resetPasswordTextField.autocapitalizationType = .none

        loginButton.enableAnimationOnPressed()
        signUpButton.enableAnimationOnPressed()


        loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped(_:)), for: .touchUpInside)


        topLogoConstraint = NSLayoutConstraint(item: logoView, attribute: .centerY, relatedBy: .equal, toItem: logoContainer, attribute: .centerY, multiplier: 1, constant: 0)

        centerLogoConstraint = NSLayoutConstraint(item: logoView, attribute: .centerY, relatedBy: .equal, toItem: logoContainer, attribute: .centerY, multiplier: 1.9, constant: 0)

        centerLogoConstraint.isActive = true
    }

    func setupBindings() {
        // Bindings
        emailTextField.reactive.text <~ viewModel.email
        passwordTextField.reactive.text <~ viewModel.password
        resetPasswordTextField.reactive.text <~ viewModel.resetPassword

        viewModel.email <~ emailTextField.reactive.continuousTextValues
        viewModel.password <~ passwordTextField.reactive.continuousTextValues
        viewModel.resetPassword <~ resetPasswordTextField.reactive.continuousTextValues

        loginAction = CocoaAction(viewModel.loginAction)
        { [weak self] _ in
            self?.showLoading()
        }
        facebookLoginAction = CocoaAction(viewModel.facebookLoginAction)
        { [weak self] _ in
            self?.showLoading()
        }
        resetPasswordAction = CocoaAction(viewModel.resetPasswordAction)
        { [weak self] _ in
            self?.showLoading()
        }

        viewModel.loginAction.events.observeValues {[weak self] in
            self?.onEvent(event: $0)
        }
        viewModel.facebookLoginAction.events.observeValues {[weak self] in
            self?.onEvent(event: $0)
        }
        viewModel.resetPasswordAction.events.observeValues {[weak self] event in
            guard let this = self else {
                return
            }
            log.debug("Action event received: \(event)")
            this.hideLoading()

            switch event {
            case .value:
                GZEAlertService.shared.showTopAlert(
                    text: this.viewModel.resetEmailSent
                )
                this.scene = .login
                break
            case .failed(let err):
                switch err {
                case .repository(let repoErr):
                    switch repoErr {
                    case .GZEApiError(let apiErr):
                        if apiErr.code == GZEApiError.Code.emailNotFound.rawValue {
                            GZEAlertService.shared.showBottomAlert(
                                text: this.viewModel.emailNotFound
                            )
                            return
                        }
                    default:
                        break
                    }
                default:
                    break
                }
                this.onError(err)
            default:
                break
            }
        }
    }

    // MARK: CocoaAction
    func onEvent(event: Event<GZEAccesToken, GZEError>) {
        log.debug("Action event received: \(event)")
        hideLoading()

        switch event {
        case .value(let token):
            switch scene {
            case .password, .login:
                onLogin(token)
            default:
                break
            }
        case .failed(let err):
            onError(err)
        default:
            break
        }
    }

    func onError(_ error: GZEError) {
        GZEAlertService.shared.showBottomAlert(text: error.localizedDescription)
    }

    func onLogin(_ accesToken: GZEAccesToken) -> Void {
        viewModel.dismiss?()
    }


    // MARK: - UIAction

    @objc func loginButtonTapped(_ sender: UIButton) {
        scene = .username
    }

    @objc func signUpButtonTapped(_ sender: UIButton) {
        showLoading()
        GZEAppConfig.loadRemote().start{[weak self] event in
            guard let this = self else {return}
            this.hideLoading()

            switch event {
            case .value(let config):
                if
                    let isRegisterCodeRequired: Bool = "isRegisterCodeRequired" <~~ config,
                    isRegisterCodeRequired
                {
                    this.viewModel.isRegisterCodeRequired = true
                } else {
                    this.viewModel.isRegisterCodeRequired = false
                }

                this.performSegue(withIdentifier: this.registerCodeSegueId, sender: this)
            case .failed(let error):
                this.onError(error)
            default:
                break
            }
        }

    }

    func backButtonTapped(_ sender: Any) {
        switch scene {
        case .username:
            scene = .login
        case .password:
            scene = .username
        case .resetPassword:
            scene = .password
        default:
            break
        }
    }

    func nextButtonTapped(_ sender: Any) {
        switch scene {
        case .username:
            scene = .password
        case .password:
            loginAction.execute(nextButton)
        case .resetPassword:
            resetPasswordAction.execute(nextButton)
        default:
            break
        }
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nextButtonTapped(textField)

        switch scene {
        case .username,
             .password,
             .resetPassword:
            return false
        default:
            log.debug("Text field without return action")
        }

        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == registerCodeSegueId {
            if let viewController = segue.destination as? GZERegisterCodeViewController
            {
                viewController.viewModel = viewModel.getSignUpViewModel()
            } else {
                log.error("Unable to parse segue.destination as? GZERegisterCodeViewController")
            }
        }
    }

    // MARK: - Scenes
    func handleSceneChanged() {
        log.debug("scene changed to: \(scene)")
        GZEAlertService.shared.dismissBottomAlert()
        switch scene {
        case .loadingTransition:
            showLoadingTransitionScene()
        case .login:
            showLoginScene()
        case .username:
            showUsernameScene()
        case .password:
            showPasswordScene()
        case .resetPassword:
            showResetPasswordScene()
        }
    }

    func showLoadingTransitionScene() {
        showNavigationBar(false, animated: true)

        logoView.alpha = 1
        bottomButton.alpha = 0
        doubleCtrlView.alpha = 0

        doubleCtrlView.topCtrlView = nil
        doubleCtrlView.bottomCtrlView = nil

        doubleCtrlView.topViewTappedHandler = nil
        doubleCtrlView.bottomViewTappedHandler = nil
    }

    func showLoginScene() {
        showNavigationBar(false, animated: true)

        logoView.alpha = 1
        bottomButton.alpha = 0
        doubleCtrlView.alpha = 1

        doubleCtrlView.topCtrlView = loginButton
        doubleCtrlView.bottomCtrlView = signUpButton

        doubleCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.loginButton.sendActions(for: .touchUpInside)
        }
        doubleCtrlView.bottomViewTappedHandler = { [unowned self] _ in
            self.signUpButton.sendActions(for: .touchUpInside)
        }
    }

    func showUsernameScene() {
        showNavigationBar(true, animated: true)

        logoView.alpha = 0
        bottomButton.alpha = 1
        doubleCtrlView.alpha = 1

        doubleCtrlView.topCtrlView = emailTextField
        doubleCtrlView.bottomCtrlView = usernameLabel

        doubleCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.emailTextField.becomeFirstResponder()
        }
        doubleCtrlView.bottomViewTappedHandler = doubleCtrlView.topViewTappedHandler

        // emailTextField.becomeFirstResponder()

        bottomButton.setAttributedTitle(viewModel.fbLoginTitle, for: .normal)
        bottomButton.removeAllTargets()
        bottomButton.addTarget(self, action: #selector(facebookLogin), for: .touchUpInside)
    }

    func showPasswordScene() {
        showNavigationBar(true, animated: true)

        logoView.alpha = 0
        bottomButton.alpha = 1
        doubleCtrlView.alpha = 1

        doubleCtrlView.topCtrlView = passwordTextField
        doubleCtrlView.bottomCtrlView = passwordLabel

        doubleCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.passwordTextField.becomeFirstResponder()
        }
        doubleCtrlView.bottomViewTappedHandler = doubleCtrlView.topViewTappedHandler

        passwordTextField.becomeFirstResponder()

        bottomButton.setAttributedTitle(nil, for: .normal)
        bottomButton.setTitle(viewModel.forgotPasswordButtonTitle, for: .normal)
        bottomButton.removeAllTargets()
        bottomButton.addTarget(self, action: #selector(forgotPassword), for: .touchUpInside)
    }

    func showResetPasswordScene() {
        showNavigationBar(true, animated: true)

        logoView.alpha = 0
        bottomButton.alpha = 0
        doubleCtrlView.alpha = 1

        doubleCtrlView.topCtrlView = resetPasswordTextField
        doubleCtrlView.bottomCtrlView = resetPasswordLabel

        doubleCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.resetPasswordTextField.becomeFirstResponder()
        }
        doubleCtrlView.bottomViewTappedHandler = doubleCtrlView.topViewTappedHandler

        resetPasswordTextField.becomeFirstResponder()
    }

    @objc func forgotPassword() {
        scene = .resetPassword
    }

    // Facebook login
    @objc func facebookLogin() {
        let fbService = GZEFacebookService.shared
        let overlay = SwiftOverlays.showCenteredWaitOverlay(self.view)

        fbService
            .login(withReadPermissions: ["email"], from: self)
            .start{[weak self] event in
                log.debug("event received: \(event)")
                overlay.removeFromSuperview()
                guard let this = self else {return}

                switch event {
                case .value(let token):
                    this.viewModel.facebookToken.value = token.tokenString
                    this.facebookLoginAction.execute(this.nextButton)
                case .failed(let error):
                    this.onError(error)
                default: break
                }
        }
    }

    // MARK: - KeyboardNotifications
    @objc func keyboardWillShow(notification: Notification) {
        log.debug("keyboard will show")
        resizeViewWithKeyboard(keyboardShow: true, constraint: viewBottomSpaceConstraint, notification: notification, view: self.view)
    }

    @objc func keyboardWillHide(notification: Notification) {
        log.debug("keyboard will hide")
        resizeViewWithKeyboard(keyboardShow: false, constraint: viewBottomSpaceConstraint, notification: notification, view: self.view, safeInsets: false)
    }

    // MARK: UINavigationControllerDelegate
    private func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DisolveInteractiveTransitioning()
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}

