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

class GZELoginViewController: UIViewController, UITextFieldDelegate {

    let registerCodeSegueId = "registerCodeSegue"

    enum Scene {
        case login
        case username
        case password
    }

    var scene = Scene.login {
        didSet {
            handleSceneChanged()
        }
    }

    var viewModel: GZELoginViewModel!

    var loginAction: CocoaAction<UIBarButtonItem>!

    let usernameLabel = UILabel()
    let passwordLabel = UILabel()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let loginButton = UIButton()
    let signUpButton = UIButton()
    let forgotPasswordButton = UIButton()

    var backButton = GZEBackUIBarButtonItem()
    var nextButton = GZENextUIBarButtonItem()

    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var doubleCtrlView: GZEDoubleCtrlView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewBottomSpaceConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("\(self) init")

        setupInterfaceObjects()
        setupBindings()

        viewModel.email.value = "admin@gooze.com"
        viewModel.password.value = "123admin"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerForKeyboarNotifications(
            observer: self,
            willShowSelector: #selector(keyboardWillShow(notification:)),
            willHideSelector: #selector(keyboardWillHide(notification:))
        )
        scene = .login
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
        loginButton.setTitle(viewModel.loginButtonTitle.uppercased(), for: .normal)
        signUpButton.setTitle(viewModel.signUpButtonTitle.uppercased(), for: .normal)
        forgotPasswordButton.setTitle(viewModel.forgotPasswordButtonTitle, for: .normal)


        emailTextField.keyboardType = .emailAddress
        emailTextField.returnKeyType = .next
        emailTextField.delegate = self
        emailTextField.autocapitalizationType = .none

        passwordTextField.returnKeyType = .send
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self


        loginButton.enableAnimationOnPressed()
        signUpButton.enableAnimationOnPressed()


        loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped(_:)), for: .touchUpInside)
    }

    func setupBindings() {
        // Bindings
        emailTextField.reactive.text <~ viewModel.email
        passwordTextField.reactive.text <~ viewModel.password

        viewModel.email <~ emailTextField.reactive.continuousTextValues
        viewModel.password <~ passwordTextField.reactive.continuousTextValues

        loginAction = CocoaAction(viewModel.loginAction)
        { [weak self] _ in
            self?.showLoading()
        }

        let onEventRef: (Event<GZEAccesToken,GZEError>) -> () = ptr(self, GZELoginViewController.onEvent)
        let onErrorRef = ptr(self, GZELoginViewController.onError)
        viewModel.loginAction.events.observeValues(onEventRef)
        viewModel.loginAction.errors.observeValues(onErrorRef)
    }

    // MARK: CocoaAction
    func onEvent<T>(event: Event<T, GZEError>) {
        log.debug("Action event received: \(event)")
        hideLoading()

        switch event {
        case .value(let value):
            switch scene {
            case .password:
                if let accesToken = value as? GZEAccesToken {
                    onLogin(accesToken)
                } else {
                    log.error("Unexpected value type[\(type(of: value))]. Expecting GZEAccesToken")
                }
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
        displayMessage(viewModel.viewTitle, error.localizedDescription)
    }

    func onLogin(_ accesToken: GZEAccesToken) -> Void {

        if
            let navController = storyboard?.instantiateViewController(withIdentifier: "SearchGoozeNavController") as? UINavigationController,
            let viewController = navController.viewControllers.first as? GZEChooseModeViewController {

            viewController.viewModel = viewModel.getChooseModeViewModel()

            setRootController(controller: navController)
        } else {
            log.error("Unable to instantiate SearchGoozeNavController")
            displayMessage(viewModel.viewTitle, GZERepositoryError.UnexpectedError.localizedDescription)
        }
    }


    // MARK: - UIAction

    func loginButtonTapped(_ sender: UIButton) {
        scene = .username
    }

    func signUpButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: registerCodeSegueId, sender: self)
    }

    func backButtonTapped(_ sender: Any) {
        switch scene {
        case .username:
            scene = .login
        case .password:
            scene = .username
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
        default:
            break
        }
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nextButtonTapped(textField)

        switch scene {
        case .username,
             .password:
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
        if
            segue.identifier == registerCodeSegueId,
            let viewController = segue.destination as? GZERegisterCodeViewController
        {
            viewController.viewModel = viewModel.getSignUpViewModel()
        }
    }

    // MARK: - Scenes
    func handleSceneChanged() {
        log.debug("scene changed to: \(scene)")
        switch scene {
        case .login:
            showLoginScene()
        case .username:
            showUsernameScene()
        case .password:
            showPasswordScene()
        }
    }

    func showLoginScene() {
        showNavigationBar(false, animated: true)

        logoView.alpha = 1

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

        doubleCtrlView.topCtrlView = emailTextField
        doubleCtrlView.bottomCtrlView = usernameLabel

        doubleCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.emailTextField.becomeFirstResponder()
        }
        doubleCtrlView.bottomViewTappedHandler = doubleCtrlView.topViewTappedHandler

        emailTextField.becomeFirstResponder()
    }

    func showPasswordScene() {
        showNavigationBar(true, animated: true)

        logoView.alpha = 0

        doubleCtrlView.topCtrlView = passwordTextField
        doubleCtrlView.bottomCtrlView = passwordLabel

        doubleCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.passwordTextField.becomeFirstResponder()
        }
        doubleCtrlView.bottomViewTappedHandler = doubleCtrlView.topViewTappedHandler

        passwordTextField.becomeFirstResponder()
    }

    // MARK: - KeyboardNotifications
    func keyboardWillShow(notification: Notification) {
        log.debug("keyboard will show")
        resizeViewWithKeyboard(keyboardShow: true, constraint: viewBottomSpaceConstraint, notification: notification)
    }

    func keyboardWillHide(notification: Notification) {
        log.debug("keyboard will hide")
        resizeViewWithKeyboard(keyboardShow: false, constraint: viewBottomSpaceConstraint, notification: notification)
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}

