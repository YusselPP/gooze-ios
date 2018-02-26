//
//  GZERegisterCodeViewController.swift
//  Gooze
//
//  Created by Yussel on 11/18/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Validator

class GZERegisterCodeViewController: UIViewController, UITextFieldDelegate {

    var viewModel: GZESignUpViewModel!

    var signupAction: CocoaAction<UIBarButtonItem>!
    var usernameExistsAction: CocoaAction<UIBarButtonItem>!
    var emailExistsAction: CocoaAction<UIBarButtonItem>!

    let signUpToProfileSegue = "signUpToProfileSegue"

    var separatorLastWidth: CGFloat = 0
    var scene: Scene = .registerCode

    enum Scene {
        case username
        case email
        case password
        case registerCode
        case facebookOrEmail
        case createOrSkipProfile
        case signupSuccess
    }

    let topTextField = UITextField()

    let topLabel = UILabel()
    let bottomLabel = UILabel()

    let topButton = UIButton()
    let bottomButton = UIButton()

    var backButton = GZEBackUIBarButtonItem()
    var nextBarButton = GZENextUIBarButtonItem()

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dblCtrlView: GZEDoubleCtrlView!
    @IBOutlet weak var scrollView: UIScrollView!

    var onActionExecutePtr: ((Any) -> Void)!
    var handleTextFieldValidationPtr: ((VValidationResult) -> Void)!
    var handleTextFieldChangedPtr: ((String?) -> Void)!
    var backButtonTappedPtr: ((UIButton) -> Void)!
    var nextButtonTappedPtr: ((Any) -> Void)!
    var onBoolEventPtr: ((Event<Bool, GZEError>) -> Void)!
    var onUserEventPtr: ((Event<GZEUser, GZEError>) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        backButtonTappedPtr = ptr(self, GZERegisterCodeViewController.backButtonTapped)
        nextButtonTappedPtr = ptr(self, GZERegisterCodeViewController.nextButtonTapped)
        onActionExecutePtr = ptr(self, GZERegisterCodeViewController.onActionExecute)
        handleTextFieldValidationPtr = ptr(self, GZERegisterCodeViewController.handleTextFieldValidation)
        handleTextFieldChangedPtr = ptr(self, GZERegisterCodeViewController.handleTextFieldChanged)
        onBoolEventPtr = ptr(self, GZERegisterCodeViewController.onEvent)
        onUserEventPtr = ptr(self, GZERegisterCodeViewController.onEvent)

        setupNavBar()

        messageLabel.alpha = 0

        topTextField.delegate = self
        topTextField.validationHandler = handleTextFieldValidationPtr

        topButton.enableAnimationOnPressed()
        bottomButton.enableAnimationOnPressed()

        topTextField.reactive
            .continuousTextValues
            .observeValues(handleTextFieldChangedPtr)

        signupAction = CocoaAction(viewModel.signupAction, onActionExecutePtr)
        usernameExistsAction = CocoaAction(viewModel.usernameExistsAction, onActionExecutePtr)
        emailExistsAction = CocoaAction(viewModel.emailExistsAction, onActionExecutePtr)

        viewModel.signupAction.events.observeValues(onUserEventPtr)
        viewModel.usernameExistsAction.events.observeValues(onBoolEventPtr)
        viewModel.emailExistsAction.events.observeValues(onBoolEventPtr)

        showRegisterCodeScene()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerForKeyboarNotifications(
            observer: self,
            willShowSelector: #selector(keyboardWillShow(notification:)),
            willHideSelector: #selector(keyboardWillHide(notification:))
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications(observer: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupNavBar() {
        backButton.onButtonTapped = backButtonTappedPtr
        nextBarButton.onButtonTapped = nextButtonTappedPtr

        navigationItem.setLeftBarButton(backButton, animated: false)
        navigationItem.setRightBarButton(nextBarButton, animated: false)
    }

    // MARK: - CocoaAction Event Handlers
    func onActionExecute(_ sender: Any) {
        showLoading()
    }

    func onEvent<T>(event: Event<T, GZEError>) {
        log.debug("Action event received: \(event)")
        hideLoading()

        switch event {
        case .value(let value):
            switch scene {
            case .username:
                if let exists = value as? Bool {
                    onUsernameExistsSuccess(exists)
                } else {
                    log.error("Unexpected value type[\(type(of: value))]. Expecting Bool")
                }
            case .email:
                if let exists = value as? Bool {
                    onEmailExistsSuccess(exists)
                } else {
                    log.error("Unexpected value type[\(type(of: value))]. Expecting Bool")
                }
            case .password:
                if let user = value as? GZEUser {
                    onSaveSuccess(user)
                } else {
                    log.error("Unexpected value type[\(type(of: value))]. Expecting GZEUser")
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

    func onUsernameExistsSuccess(_ exists: Bool) {
        if exists {
            let error = GZEValidationError
                .exists(fieldName: GZEUser.Validation.username.fieldName)

            displayMessage(viewModel.viewTitle, error.localizedDescription)
        } else {
            showEmailScene()
        }
    }

    func onEmailExistsSuccess(_ exists: Bool) {
        if exists {
            let error = GZEValidationError
                .exists(fieldName: GZEUser.Validation.email.fieldName)

            displayMessage(viewModel.viewTitle, error.localizedDescription)
        } else {
            showPasswordScene()
        }
    }

    func onSaveSuccess(_ user: GZEUser) {
        showSignupSuccessScene()
    }

    func onError(_ error: GZEError) {
        displayMessage(viewModel.viewTitle, error.localizedDescription)
    }

    // MARK: Scenes

    func showRegisterCodeScene() {

        scene = .registerCode

        backButton.isEnabled = true
        nextBarButton.isEnabled = true

        topTextField.returnKeyType = .next
        topTextField.keyboardType = .default
        topTextField.isSecureTextEntry = false
        topTextField.text = viewModel.registerCode.value
        // TODO: Define registerCode validations
        // topTextField.validationRules = GZESignUpViewModel.validationRule.registerCode.stringRules

        bottomLabel.setText(viewModel.registerCodeLabelText.uppercased(), animated: true)

        dblCtrlView.separatorWidth = 180
        separatorLastWidth = dblCtrlView.separatorWidth
        dblCtrlView.topCtrlView = topTextField
        dblCtrlView.bottomCtrlView = bottomLabel

        dblCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.topTextField.becomeFirstResponder()
        }
        dblCtrlView.bottomViewTappedHandler = dblCtrlView.topViewTappedHandler
    }

    func showUsernameScene() {

        scene = .username

        backButton.isEnabled = true
        nextBarButton.isEnabled = true

        topTextField.returnKeyType = .next
        topTextField.keyboardType = .default
        topTextField.isSecureTextEntry = false
        topTextField.text = viewModel.username.value
        topTextField.validationRules = GZESignUpViewModel.validationRule.username.stringRules

        bottomLabel.setText(viewModel.usernameLabelText.uppercased(), animated: true)

        dblCtrlView.separatorWidth = 100
        separatorLastWidth = dblCtrlView.separatorWidth

        dblCtrlView.topCtrlView = topTextField
        dblCtrlView.bottomCtrlView = bottomLabel

        dblCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.topTextField.becomeFirstResponder()
        }
        dblCtrlView.bottomViewTappedHandler = dblCtrlView.topViewTappedHandler
    }

    func showFacebookOrEmailScene() {

        scene = .facebookOrEmail

        backButton.isEnabled = true
        nextBarButton.isEnabled = true

        topButton.setTitle(viewModel.facebookSignUp.uppercased(), for: .normal)
        bottomButton.setTitle(viewModel.emailLabelText.uppercased(), for: .normal)

        topButton.removeAllTargets()
        bottomButton.removeAllTargets()

        // topButton.addTarget(self, action: #selector(), for: .touchUpInside)
        bottomButton.addTarget(self, action: #selector(showEmailScene), for: .touchUpInside)


        dblCtrlView.separatorWidth = 240
        separatorLastWidth = dblCtrlView.separatorWidth
        dblCtrlView.topCtrlView = topButton
        dblCtrlView.bottomCtrlView = bottomButton

        dblCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.topButton.sendActions(for: .touchUpInside)
        }
        dblCtrlView.bottomViewTappedHandler = { [unowned self] _ in
            self.bottomButton.sendActions(for: .touchUpInside)
        }
    }

    func showEmailScene() {

        scene = .email

        backButton.isEnabled = true
        nextBarButton.isEnabled = true

        topTextField.returnKeyType = .next
        topTextField.keyboardType = .emailAddress
        topTextField.isSecureTextEntry = false
        topTextField.text = viewModel.email.value
        topTextField.validationRules = GZESignUpViewModel.validationRule.email.stringRules

        bottomLabel.setText(viewModel.emailLabelText.uppercased(), animated: true)

        dblCtrlView.separatorWidth = 200
        separatorLastWidth = dblCtrlView.separatorWidth
        dblCtrlView.topCtrlView = topTextField
        dblCtrlView.bottomCtrlView = bottomLabel

        dblCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.topTextField.becomeFirstResponder()
        }
        dblCtrlView.bottomViewTappedHandler = dblCtrlView.topViewTappedHandler
    }

    func showPasswordScene() {

        scene = .password

        backButton.isEnabled = true
        nextBarButton.isEnabled = true

        topTextField.returnKeyType = .send
        topTextField.keyboardType = .default
        topTextField.isSecureTextEntry = true
        topTextField.text = viewModel.password.value
        topTextField.validationRules = GZESignUpViewModel.validationRule.password.stringRules

        bottomLabel.setText(viewModel.passwordLabelText.uppercased(), animated: true)

        dblCtrlView.separatorWidth = 120
        separatorLastWidth = dblCtrlView.separatorWidth
        dblCtrlView.topCtrlView = topTextField
        dblCtrlView.bottomCtrlView = bottomLabel

        dblCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.topTextField.becomeFirstResponder()
        }
        dblCtrlView.bottomViewTappedHandler = dblCtrlView.topViewTappedHandler
    }

    func showSignupSuccessScene() {

        scene = .signupSuccess

        navigationItem.setLeftBarButton(nil, animated: true)
        navigationItem.setRightBarButton(nil, animated: true)

        messageLabel.text = viewModel.successfulSignUp.uppercased()

        topLabel.setText(viewModel.createProfileText.uppercased(), animated: true)
        bottomLabel.setText(viewModel.skipProfileText.uppercased(), animated: true)

        dblCtrlView.separatorWidth = 120
        separatorLastWidth = dblCtrlView.separatorWidth
        dblCtrlView.topCtrlView = topLabel
        dblCtrlView.bottomCtrlView = bottomLabel

        (dblCtrlView.topCtrlView as? UILabel)?.textColor = GZEConstants.Color.textInputPlacehoderOnEdit
        (dblCtrlView.bottomCtrlView as? UILabel)?.textColor = GZEConstants.Color.textInputPlacehoderOnEdit

        dblCtrlView.topViewTappedHandler = nil
        dblCtrlView.bottomViewTappedHandler = nil

        UIView.animate(withDuration: 3, animations: { [weak self] in
            self?.messageLabel.alpha = 1
        }) { [weak self] _ in
            self?.showCreateOrSkipProfile()
        }
    }

    func showCreateOrSkipProfile() {

        scene = .createOrSkipProfile

        backButton.isEnabled = false
        nextBarButton.isEnabled = false

        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.messageLabel.textColor = GZEConstants.Color.textInputPlacehoderOnEdit
        })

        topButton.setTitle(viewModel.createProfileText.uppercased(), for: .normal)
        bottomButton.setTitle(viewModel.skipProfileText.uppercased(), for: .normal)

        topButton.removeAllTargets()
        bottomButton.removeAllTargets()

        topButton.addTarget(self, action: #selector(createProfileController), for: .touchUpInside)
        bottomButton.addTarget(self, action: #selector(chooseModeController), for: .touchUpInside)


        dblCtrlView.separatorWidth = 120
        separatorLastWidth = dblCtrlView.separatorWidth
        dblCtrlView.topCtrlView = topButton
        dblCtrlView.bottomCtrlView = bottomButton

        dblCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.topButton.sendActions(for: .touchUpInside)
        }
        dblCtrlView.bottomViewTappedHandler = { [unowned self] _ in
            self.bottomButton.sendActions(for: .touchUpInside)
        }
    }

    // MARK: UIActions

    func backButtonTapped(_ sender: UIButton) {
        switch scene {
        case .registerCode:
            previousController(animated: true)
        case .username:
            showRegisterCodeScene()
        case .facebookOrEmail:
            showUsernameScene()
        case .email:
            showFacebookOrEmailScene()
        case .password:
            showEmailScene()
        default:
            break
        }
    }

    func nextButtonTapped(_ sender: Any) {
        switch scene {
        case .registerCode:
            showUsernameScene()
        case .username,
             .email,
             .password:
            topTextField.validate()
        case .facebookOrEmail:
            showEmailScene()
        default:
            break
        }
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        // TODO: Hide white line until star typing
        nextButtonTapped(textField)

        switch scene {
            // Textfields with validation
        case .username,
             .email,
             .password:
            return false
        default:
            break
        }

        return true
    }

    func handleTextFieldChanged(value: String?) {
        switch scene {
        case .username:
            viewModel.username.value = value
        case .email:
            viewModel.email.value = value
        case .password:
            viewModel.password.value = value
        case .registerCode:
            viewModel.registerCode.value = value
        default:
            break
        }
    }

    // Caled after textField.validate()
    func handleTextFieldValidation(result: VValidationResult) {
        switch result {
        case .valid:
            log.debug("textfield has valid input")
            switch scene {
            case .username:
                usernameExistsAction.execute(nextBarButton)
            case .email:
                emailExistsAction.execute(nextBarButton)
            case .password:
                signupAction.execute(nextBarButton)
            default:
                break
            }
        case .invalid(let failureErrors):
            log.debug(failureErrors)
            var msg: String
            if let description = failureErrors.first?.localizedDescription {
                msg = description
            } else {
                msg = viewModel.textFieldValidationFailed
            }
            displayMessage(viewModel.viewTitle, msg)
        }
    }

    // MARK: KeyboardNotifications

    func keyboardWillShow(notification: Notification) {
        log.debug("keyboard will show")
        log.debug(notification.userInfo as Any)

        (dblCtrlView.bottomCtrlView as? UILabel)?.textColor = GZEConstants.Color.textInputPlacehoderOnEdit
        separatorLastWidth = dblCtrlView.separatorWidth
        dblCtrlView.separatorWidth = 0
        addKeyboardInsetAndScroll(scrollView: scrollView, activeField: dblCtrlView, notification: notification)
    }

    func keyboardWillHide(notification: Notification) {
        log.debug("keyboard will hide")
        (dblCtrlView.bottomCtrlView as? UILabel)?.textColor = .white
        removeKeyboardInset(scrollView: scrollView)
        dblCtrlView.separatorWidth = separatorLastWidth
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if
            segue.identifier == signUpToProfileSegue,
            let viewController = segue.destination as? GZESignUpProfileViewController
        {
            viewController.viewModel = viewModel
        }
    }

    func createProfileController() {
        performSegue(withIdentifier: signUpToProfileSegue, sender: nil)
    }

    func chooseModeController() {
        // TODO: send to choose mode vc instead
        previousController(animated: true)
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
