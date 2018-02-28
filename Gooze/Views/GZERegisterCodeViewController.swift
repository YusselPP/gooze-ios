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

    @IBOutlet weak var viewBottomSpaceConstraint: NSLayoutConstraint!

    // Method weak references
    var onActionExecute: ((Any) -> Void)!
    var onTextFieldValidation: ((VValidationResult) -> Void)!
    var onTextFieldChanged: ((String?) -> Void)!
    var onBackButtonTapped: ((UIButton) -> Void)!
    var onNextButtonTapped: ((Any) -> Void)!
    var onBoolEvent: ((Event<Bool, GZEError>) -> Void)!
    var onUserEvent: ((Event<GZEUser, GZEError>) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        createMethodWeakReferences()

        setupNavBar()

        createActions()

        messageLabel.alpha = 0
        topButton.enableAnimationOnPressed()
        bottomButton.enableAnimationOnPressed()
        topButton.setTitleColor(GZEConstants.Color.textInputPlacehoderOnEdit, for: .disabled)
        bottomButton.setTitleColor(GZEConstants.Color.textInputPlacehoderOnEdit, for: .disabled)

        topTextField.delegate = self
        topTextField.validationHandler = onTextFieldValidation
        topTextField.reactive.continuousTextValues.observeValues(onTextFieldChanged)

        showRegisterCodeScene()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerForKeyboarNotifications(
            observer: self,
            willShowSelector: #selector(keyboardWillShow(notification:)),
            willHideSelector: #selector(keyboardWillHide(notification:))
        )
        if scene == .createOrSkipProfile || scene == .signupSuccess {
            showNavigationBar(false, animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications(observer: self)
        showNavigationBar(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createMethodWeakReferences() {
        onBackButtonTapped = ptr(self, GZERegisterCodeViewController.backButtonTapped)
        onNextButtonTapped = ptr(self, GZERegisterCodeViewController.nextButtonTapped)
        onActionExecute = ptr(self, GZERegisterCodeViewController.handleActionExecute)
        onTextFieldValidation = ptr(self, GZERegisterCodeViewController.handleTextFieldValidation)
        onTextFieldChanged = ptr(self, GZERegisterCodeViewController.handleTextFieldChanged)
        onBoolEvent = ptr(self, GZERegisterCodeViewController.onEvent)
        onUserEvent = ptr(self, GZERegisterCodeViewController.onEvent)
    }

    func createActions() {
        signupAction = CocoaAction(viewModel.signupAction, onActionExecute)
        usernameExistsAction = CocoaAction(viewModel.usernameExistsAction, onActionExecute)
        emailExistsAction = CocoaAction(viewModel.emailExistsAction, onActionExecute)

        viewModel.signupAction.events.observeValues(onUserEvent)
        viewModel.usernameExistsAction.events.observeValues(onBoolEvent)
        viewModel.emailExistsAction.events.observeValues(onBoolEvent)
    }

    func setupNavBar() {
        backButton.onButtonTapped = onBackButtonTapped
        nextBarButton.onButtonTapped = onNextButtonTapped

        navigationItem.setLeftBarButton(backButton, animated: false)
        navigationItem.setRightBarButton(nextBarButton, animated: false)
    }

    // MARK: - CocoaAction Event Handlers
    func handleActionExecute(_ sender: Any) {
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
            showFacebookOrEmailScene()
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

    // MARK: - KeyboardNotifications

    func keyboardWillShow(notification: Notification) {
        log.debug("keyboard will show")
        resizeViewWithKeyboard(keyboardShow: true, constraint: viewBottomSpaceConstraint, notification: notification)
    }

    func keyboardWillHide(notification: Notification) {
        log.debug("keyboard will hide")
        resizeViewWithKeyboard(keyboardShow: false, constraint: viewBottomSpaceConstraint, notification: notification)
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

    // MARK: Scenes
    func showRegisterCodeScene() {
        scene = .registerCode

        showNavigationBar(true, animated: true)

        topTextField.returnKeyType = .next
        topTextField.keyboardType = .default
        topTextField.isSecureTextEntry = false
        topTextField.text = viewModel.registerCode.value
        // TODO: Define registerCode validations
        // topTextField.validationRules = GZESignUpViewModel.validationRule.registerCode.stringRules

        bottomLabel.setText(viewModel.registerCodeLabelText.uppercased(), animated: true)

        dblCtrlView.topCtrlView = topTextField
        dblCtrlView.bottomCtrlView = bottomLabel

        dblCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.topTextField.becomeFirstResponder()
        }
        dblCtrlView.bottomViewTappedHandler = dblCtrlView.topViewTappedHandler
        // Mess with scrolling when view is being loaded
        topTextField.becomeFirstResponder()
    }

    func showUsernameScene() {
        scene = .username

        showNavigationBar(true, animated: true)

        topTextField.returnKeyType = .next
        topTextField.keyboardType = .default
        topTextField.isSecureTextEntry = false
        topTextField.text = viewModel.username.value
        topTextField.validationRules = GZESignUpViewModel.validationRule.username.stringRules

        bottomLabel.setText(viewModel.usernameLabelText.uppercased(), animated: true)

        dblCtrlView.topCtrlView = topTextField
        dblCtrlView.bottomCtrlView = bottomLabel

        dblCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.topTextField.becomeFirstResponder()
        }
        dblCtrlView.bottomViewTappedHandler = dblCtrlView.topViewTappedHandler
        topTextField.becomeFirstResponder()
    }

    func showFacebookOrEmailScene() {
        scene = .facebookOrEmail

        showNavigationBar(true, animated: true)

        topButton.setTitle(viewModel.facebookSignUp.uppercased(), for: .normal)
        bottomButton.setTitle(viewModel.emailLabelText.uppercased(), for: .normal)

        topButton.removeAllTargets()
        bottomButton.removeAllTargets()

        // TODO: Implement facebook login
        // topButton.addTarget(self, action: #selector(), for: .touchUpInside)
        bottomButton.addTarget(self, action: #selector(showEmailScene), for: .touchUpInside)

        topButton.isEnabled = true
        bottomButton.isEnabled = true

        dblCtrlView.topCtrlView = topButton
        dblCtrlView.bottomCtrlView = bottomButton

        dblCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.topButton.sendActions(for: .touchUpInside)
        }
        dblCtrlView.bottomViewTappedHandler = { [unowned self] _ in
            self.bottomButton.sendActions(for: .touchUpInside)
        }
        topTextField.resignFirstResponder()
    }

    func showEmailScene() {
        scene = .email

        showNavigationBar(true, animated: true)

        topTextField.returnKeyType = .next
        topTextField.keyboardType = .emailAddress
        topTextField.isSecureTextEntry = false
        topTextField.text = viewModel.email.value
        topTextField.validationRules = GZESignUpViewModel.validationRule.email.stringRules

        bottomLabel.setText(viewModel.emailLabelText.uppercased(), animated: true)

        dblCtrlView.topCtrlView = topTextField
        dblCtrlView.bottomCtrlView = bottomLabel

        dblCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.topTextField.becomeFirstResponder()
        }
        dblCtrlView.bottomViewTappedHandler = dblCtrlView.topViewTappedHandler
        topTextField.becomeFirstResponder()
    }

    func showPasswordScene() {
        scene = .password

        showNavigationBar(true, animated: true)

        topTextField.returnKeyType = .send
        topTextField.keyboardType = .default
        topTextField.isSecureTextEntry = true
        topTextField.text = viewModel.password.value
        topTextField.validationRules = GZESignUpViewModel.validationRule.password.stringRules

        bottomLabel.setText(viewModel.passwordLabelText.uppercased(), animated: true)

        dblCtrlView.topCtrlView = topTextField
        dblCtrlView.bottomCtrlView = bottomLabel

        dblCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.topTextField.becomeFirstResponder()
        }
        dblCtrlView.bottomViewTappedHandler = dblCtrlView.topViewTappedHandler
        topTextField.becomeFirstResponder()
    }

    func showSignupSuccessScene() {
        scene = .signupSuccess

        showNavigationBar(false, animated: true)

        messageLabel.text = viewModel.successfulSignUp.uppercased()

        topLabel.text = viewModel.createProfileText.uppercased()
        bottomLabel.text = viewModel.skipProfileText.uppercased()

        dblCtrlView.topCtrlView = topLabel
        dblCtrlView.bottomCtrlView = bottomLabel

        topLabel.textColor = GZEConstants.Color.textInputPlacehoderOnEdit
        bottomLabel.textColor = GZEConstants.Color.textInputPlacehoderOnEdit

        dblCtrlView.topViewTappedHandler = nil
        dblCtrlView.bottomViewTappedHandler = nil

        UIView.animate(withDuration: 1, animations: { [weak self] in
            self?.messageLabel.alpha = 1
        }) { [weak self] _ in
            self?.showCreateOrSkipProfile()
        }
        topTextField.resignFirstResponder()
    }

    func showCreateOrSkipProfile() {
        scene = .createOrSkipProfile

        showNavigationBar(false, animated: true)

        messageLabel.setColor(GZEConstants.Color.textInputPlacehoderOnEdit, animated: true)

        topLabel.setColor(GZEConstants.Color.mainTextColor, animated: true)
        bottomLabel.setColor(GZEConstants.Color.mainTextColor, animated: true)

        dblCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.createProfileController()
        }
        dblCtrlView.bottomViewTappedHandler = { [unowned self] _ in
            self.chooseModeController()
        }
        topTextField.resignFirstResponder()
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
