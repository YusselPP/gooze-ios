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

    var viewModel: GZELoginViewModel!

    var loginAction: CocoaAction<UIButton>!
    var loginSuccesObserver: Disposable?
    var loginErrorObserver: Disposable?

    let signUpSegueId = "signUpSegue"
    let registerCodeSegueId = "registerCodeSegue"

    let usernameLabel = UILabel()
    let passwordLabel = UILabel()
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let loginButton = UIButton()
    let signUpButton = UIButton()
    let forgotPasswordButton = UIButton()

    var backButton = UIBarButtonItem()

    @IBOutlet weak var doubleCtrlView: GZEDoubleCtrlView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        setupInterfaceObjects()

        setupBindings()

        showLoginScene()

        emailTextField.text = "admin@gooze.com"
        passwordTextField.text = "123admin"
    }

    override func viewWillAppear(_ animated: Bool) {
        registerForKeyboarNotifications(
            observer: self,
            didShowSelector: #selector(keyboardShown(notification:)),
            willHideSelector: #selector(keyboardWillHide(notification:))
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications(observer: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupInterfaceObjects() {

        backButton.image = #imageLiteral(resourceName: "icons8-back-50")
        backButton.target = self

        // Titles
        usernameLabel.text = viewModel.usernameLabel.uppercased()
        passwordLabel.text = viewModel.passwordLabel.uppercased()
        loginButton.setTitle(viewModel.loginButtonTitle.uppercased(), for: .normal)
        signUpButton.setTitle(viewModel.signUpButtonTitle.uppercased(), for: .normal)
        forgotPasswordButton.setTitle(viewModel.forgotPasswordButtonTitle, for: .normal)


        emailTextField.keyboardType = .emailAddress
        emailTextField.returnKeyType = .next
        emailTextField.delegate = self

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
        viewModel.email <~ emailTextField.reactive.continuousTextValues
        viewModel.password <~ passwordTextField.reactive.continuousTextValues

        loginAction = CocoaAction(viewModel.loginAction)
        { [weak self] _ in
            self?.showLoading()
        }
        // loginButton.reactive.pressed = loginAction


        loginSuccesObserver = viewModel.loginAction.values.observeValues(onLogin)

        loginErrorObserver = viewModel.loginAction.errors.observeValues(onLoginError)
    }

    // MARK: Observer handlers

    func onLogin(user: GZEAccesToken) -> Void {

        hideLoading()
        
        if
            let navController = storyboard?.instantiateViewController(withIdentifier: "SearchGoozeNavController") as? UINavigationController,
            let viewController = navController.viewControllers.first as? GZEChooseModeViewController {

            loginSuccesObserver?.dispose()
            loginErrorObserver?.dispose()

            viewController.viewModel = viewModel.getChooseModeViewModel()

            setRootController(controller: navController)
        } else {
            log.error("Unable to instantiate SearchGoozeNavController")
            displayMessage(viewModel.viewTitle, GZERepositoryError.UnexpectedError.localizedDescription)
        }
    }

    func onLoginError(err: GZEError) {
        hideLoading()
        displayMessage(viewModel.viewTitle, err.localizedDescription)
    }



    // MARK: - Actions

    func loginButtonTapped(_ sender: UIButton) {
        showUsernameScene()
    }

    func signUpButtonTapped(_ sender: UIButton) {

        if GZEAppConfig.useRegisterCode {
            performSegue(withIdentifier: registerCodeSegueId, sender: self)
        } else {
            performSegue(withIdentifier: signUpSegueId, sender: self)
        }
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        switch textField {
        case emailTextField:
            showPasswordScene()
            return false
        case passwordTextField:
            loginAction.execute(loginButton)
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
            segue.identifier == signUpSegueId,
            let viewController = segue.destination as? GZESignUpBasicViewController
        {
            viewController.viewModel = viewModel.getSignUpViewModel()

        } else if
            segue.identifier == registerCodeSegueId,
            let viewController = segue.destination as? GZERegisterCodeViewController
        {
            viewController.viewModel = viewModel.getRegisterCodeViewModel()
        }
    }

    func showLoginScene() {
        navigationItem.setLeftBarButton(nil, animated: true)
        backButton.action = nil

        doubleCtrlView.separatorWidth = 130
        doubleCtrlView.topCtrlView = loginButton
        doubleCtrlView.bottomCtrlView = signUpButton

        doubleCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.loginButton.sendActions(for: .touchUpInside)
        }
        doubleCtrlView.bottomViewTappedHandler = { [unowned self] _ in
            self.signUpButton.sendActions(for: .touchUpInside)
        }
        emailTextField.resignFirstResponder()
    }

    func showUsernameScene() {
        navigationItem.setLeftBarButton(backButton, animated: true)
        backButton.action = #selector(showLoginScene)

        doubleCtrlView.separatorWidth = 0
        doubleCtrlView.topCtrlView = emailTextField
        doubleCtrlView.bottomCtrlView = usernameLabel

        doubleCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.emailTextField.becomeFirstResponder()
        }
        doubleCtrlView.bottomViewTappedHandler = doubleCtrlView.topViewTappedHandler

        passwordTextField.resignFirstResponder()
        emailTextField.becomeFirstResponder()
    }

    func showPasswordScene() {
        navigationItem.setLeftBarButton(backButton, animated: true)
        backButton.action = #selector(showUsernameScene)

        doubleCtrlView.separatorWidth = 0
        doubleCtrlView.topCtrlView = passwordTextField
        doubleCtrlView.bottomCtrlView = passwordLabel

        doubleCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.passwordTextField.becomeFirstResponder()
        }
        doubleCtrlView.bottomViewTappedHandler = doubleCtrlView.topViewTappedHandler
        emailTextField.resignFirstResponder()
        passwordTextField.becomeFirstResponder()
    }

    // MARK: KeyboardNotifications

    func keyboardShown(notification: Notification) {
        log.debug("keyboard shown")
        (doubleCtrlView.bottomCtrlView as? UILabel)?.textColor = GZEConstants.Color.textInputPlacehoderOnEdit
        addKeyboardInsetAndScroll(scrollView: scrollView, activeField: doubleCtrlView, notification: notification)
    }

    func keyboardWillHide(notification: Notification) {
        log.debug("keyboard will hide")
        (doubleCtrlView.bottomCtrlView as? UILabel)?.textColor = .white
        removeKeyboardInset(scrollView: scrollView)
    }

    // MARK: Deinitializers
    deinit {
        emailTextField.delegate = nil
        passwordTextField.delegate = nil
        log.debug("\(self) disposed")
    }
}

