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
    var saveAction: CocoaAction<UIBarButtonItem>!

    let signUpSegueId = "signUpSegue"
    let signUpToProfileSegue = "signUpToProfileSegue"

    let topTextField = GZETextField()

    let topLabel = UILabel()
    let bottomLabel = UILabel()

    let topButton = UIButton()
    let bottomButton = UIButton()

    let backButton = UIBarButtonItem()

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

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dblCtrlView: GZEDoubleCtrlView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nextBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        backButton.image = #imageLiteral(resourceName: "icons8-back-50")
        backButton.target = self
        navigationItem.setLeftBarButton(backButton, animated: false)
        nextBarButton.target = self

        messageLabel.alpha = 0

        topTextField.delegate = self
        topButton.enableAnimationOnPressed()
        bottomButton.enableAnimationOnPressed()

        topTextField.reactive.continuousTextValues.observeValues(handleTextFieldChanged)

        saveAction = CocoaAction(viewModel.saveAction)
        { [weak self] _ in
            self?.showLoading()
        }

        viewModel.saveAction.values.observeValues(onSaveSuccess)
        viewModel.saveAction.errors.observeValues(onSaveError)

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
            break;
        }
    }

    func save() {
        saveAction.execute(nextBarButton)
    }

    func onSaveSuccess(user: GZEUser) {
        hideLoading()
        showSignupSuccessScene()
    }

    func onSaveError(error: GZEError) {
        hideLoading()
        displayMessage(viewModel.viewTitle, error.localizedDescription)
    }


    // MARK: Scenes

    func showRegisterCodeScene() {

        scene = .registerCode

        backButton.action = #selector(previousController)
        nextBarButton.action = #selector(showUsernameScene)

        topTextField.returnKeyType = .next
        topTextField.keyboardType = .default
        topTextField.isSecureTextEntry = false
        topTextField.text = viewModel.registerCode.value

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

        backButton.action = #selector(showRegisterCodeScene)
        nextBarButton.action = #selector(showFacebookOrEmailScene)

        topTextField.returnKeyType = .next
        topTextField.keyboardType = .default
        topTextField.isSecureTextEntry = false
        topTextField.text = viewModel.username.value

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

        backButton.action = #selector(showUsernameScene)
        nextBarButton.action = #selector(showEmailScene)

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

        backButton.action = #selector(showFacebookOrEmailScene)
        nextBarButton.action = #selector(showPasswordScene)

        topTextField.returnKeyType = .next
        topTextField.keyboardType = .emailAddress
        topTextField.isSecureTextEntry = false
        topTextField.text = viewModel.email.value

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

        backButton.action = #selector(showEmailScene)
        nextBarButton.action = #selector(save)

        topTextField.returnKeyType = .send
        topTextField.keyboardType = .default
        topTextField.isSecureTextEntry = true
        topTextField.text = viewModel.password.value

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

        backButton.action = #selector(showPasswordScene)
        nextBarButton.action = #selector(showCreateOrSkipProfile)

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

        backButton.action = #selector(previousController)
        nextBarButton.action = #selector(createProfileController)

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

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        // TODO: Add field validations
        switch scene {
        case .registerCode:
            showUsernameScene()
            //return false
        case .username:
            showFacebookOrEmailScene()
            //return false
        case .email:
            showPasswordScene()
            //return false
        case .password:
            save()
            //return false
        default:
            log.debug("Text field without return action")
        }

        textField.resignFirstResponder()
        return true
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
            segue.identifier == signUpSegueId,
            let viewController = segue.destination as? GZESignUpBasicViewController
        {
            viewController.viewModel = viewModel

        } else if
            segue.identifier == signUpToProfileSegue,
            let viewController = segue.destination as? GZESignUpProfileViewController
        {
            viewController.viewModel = viewModel
        }
    }

    func previousController() {
        navigationController?.popViewController(animated: true)
    }

    func createProfileController() {
        performSegue(withIdentifier: signUpToProfileSegue, sender: nil)
    }

    func chooseModeController() {
        
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
