//
//  GZESignUpProfileViewController.swift
//  Gooze
//
//  Created by Yussel on 12/23/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZESignUpProfileViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate {

    let profileToPhotoEditSegue = "profileToPhotoEditSegue"

    var viewModel: GZESignUpViewModel!

    var updateAction: CocoaAction<UIButton>!

    var activeField: UITextField?

    enum Scene {
        case phrase
        case gender
        case birthday
        case height
        case weight
        case origin
        case language
        case interests
    }
    var _scene: Scene = .phrase
    var scene: Scene {
        get { return _scene }
        set(newScene){ setScene(newScene) }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var bottomReferenceView: UIView!

    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var phraseTextField: GZETextField!
    @IBOutlet weak var genderTextField: GZETextField!
    @IBOutlet weak var birthdayTextField: GZETextField!
    @IBOutlet weak var heightTextField: GZETextField!
    @IBOutlet weak var weightTextField: GZETextField!
    @IBOutlet weak var originTextField: GZETextField!
    @IBOutlet weak var languageTextField: GZETextField!
    @IBOutlet weak var interestsTextField: GZETextField!

    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    let birthdayPicker = UIDatePicker()
    let genderPicker = UIPickerView()

    let backButton = GZEBackUIBarButtonItem()
    let nextButton = GZENextUIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        /*loadLoggedUser().start { [weak self] in
            switch $0 {
            case .value(let user):
                self?.viewModel.user = user
            case .failed(let err):
                self?.onError(err)
            default: break
            }
        }*/

        setupInterfaceObjects()
        setupBindings()
        setupActions()

        showPhraseScene()

        // TODO: How to know what gender search for
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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        log.debug("View Will Transition to size: \(size)")

        coordinator.animate(alongsideTransition: nil) { [unowned self] _ in
            log.debug("View did Transition to size: \(size)")
            log.debug("Status bar landscape? \(UIApplication.shared.statusBarOrientation.isLandscape)")
            log.debug("Status bar portrait? \(UIApplication.shared.statusBarOrientation.isPortrait)")

            log.debug("Scroll content view: \(self.scrollContentView.frame)")
            log.debug("Bottom reference view: \(self.bottomReferenceView.frame)")
        }
        super.viewWillTransition(to: size, with: coordinator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupInterfaceObjects() {
        navigationItem.hidesBackButton = true
        navigationItem.setRightBarButton(nextButton, animated: false)

        skipButton.setTitle(viewModel.skipProfileText.uppercased(), for: .normal)
        saveButton.setTitle(viewModel.saveButtonTitle.uppercased(), for: .normal)

        setTextFieldFormat(phraseTextField, placeholder:  viewModel.phraseLabelText.addQuotes() )
        setTextFieldFormat(genderTextField, placeholder: viewModel.genderLabelText)
        setTextFieldFormat(birthdayTextField, placeholder: viewModel.birthdayLabelText)
        setTextFieldFormat(heightTextField, placeholder: viewModel.heightLabelText)
        setTextFieldFormat(weightTextField, placeholder: viewModel.weightLabelText)
        setTextFieldFormat(originTextField, placeholder: viewModel.originLabelText)
        setTextFieldFormat(languageTextField, placeholder: viewModel.languageLabelText)
        setTextFieldFormat(interestsTextField, placeholder: viewModel.interestsLabelText)

        interestsTextField.returnKeyType = .done

        heightTextField.validationRules = GZEUser.Validation.height.stringRule()
        weightTextField.validationRules = GZEUser.Validation.weight.stringRule()

        let toolBar = GZEPickerUIToolbar()
        toolBar.onDone = ptr(self, GZESignUpProfileViewController.pickerDoneTapped)
        toolBar.onClose = ptr(self, GZESignUpProfileViewController.pickerCloseTapped)


        birthdayPicker.datePickerMode = .date
        birthdayPicker.maximumDate = Date()
        birthdayTextField.inputView = birthdayPicker
        birthdayTextField.inputAccessoryView = toolBar

        genderPicker.dataSource = viewModel
        genderPicker.delegate = self
        genderTextField.inputView = genderPicker
        genderTextField.inputAccessoryView = toolBar
    }

    func setupBindings() {
        // Out bindings
        usernameLabel.reactive.text <~ viewModel.username.map { $0?.uppercased() }
        profileImageView.reactive.image <~ viewModel.profilePic
        phraseTextField.reactive.text <~ viewModel.phrase
        genderTextField.reactive.text <~ viewModel.gender.map { $0?.displayValue }
        birthdayTextField.reactive.text <~ viewModel.birthday.map {
            $0.flatMap { GZEDateHelper.displayDateFormatter.string(from: $0) }
        }
        heightTextField.reactive.text <~ viewModel.height
        weightTextField.reactive.text <~ viewModel.weight
        originTextField.reactive.text <~ viewModel.origin
        languageTextField.reactive.text <~ viewModel.languages
        interestsTextField.reactive.text <~ viewModel.interestedIn

        // In bindings
        viewModel.phrase <~ phraseTextField.reactive.continuousTextValues
        // viewModel.gender is set through picker delegate,
        // because it doesn't have reactive interface
        viewModel.birthday <~ birthdayPicker.reactive.dates
        viewModel.height <~ heightTextField.reactive.continuousTextValues
        viewModel.weight <~ weightTextField.reactive.continuousTextValues
        viewModel.origin <~ originTextField.reactive.continuousTextValues
        viewModel.languages <~ languageTextField.reactive.continuousTextValues
        viewModel.interestedIn <~ interestsTextField.reactive.continuousTextValues
    }

    func setupActions() {
        backButton.onButtonTapped = ptr(self, GZESignUpProfileViewController.backButtonTapped)
        nextButton.onButtonTapped = ptr(self, GZESignUpProfileViewController.nextButtonTapped)
        saveButton.addTarget(self, action: #selector(updateProfile), for: .touchUpInside)
        
        updateAction = CocoaAction(viewModel.updateAction)
        { [weak self] _ in
            self?.showLoading()
        }
        viewModel.updateAction.events.observeValues(ptr(self, GZESignUpProfileViewController.onEvent))
    }

    func setTextFieldFormat(_ textField: UITextField, placeholder: String) {
        textField.delegate = self

        textField.returnKeyType = .next
        textField.isHidden = true
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = .none
        textField.textColor = UIColor.white
        textField.textAlignment = .center
        textField.font = UIFont(name: "HelveticaNeue", size: 17)!
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 17)!])
    }

    // MARK: - CocoaAction
    func onEvent(event: Event<GZEUser, GZEError>) {
        log.debug("Action event received: \(event)")
        hideLoading()

        switch event {
        case .value(let user):
            onUpdateSuccess(user)
        case .failed(let err):
            onError(err)
        default:
            break
        }
    }

    func onUpdateSuccess(_ user: GZEUser) {
        performSegue(withIdentifier: profileToPhotoEditSegue, sender: saveButton)
    }

    func onError(_ error: GZEError) {
        displayMessage(viewModel.viewTitle, error.localizedDescription)
    }

    // MARK: - UIActions
    @IBAction func editPhotoTapped(_ sender: Any) {
        performSegue(withIdentifier: profileToPhotoEditSegue, sender: nil)
    }

    @IBAction func skipButtonTapped(_ sender: Any) {
        showChooseModeController()
    }

    func pickerDoneTapped(_ sender: UIBarButtonItem) {
        if let field = activeField {
            if textFieldShouldReturn(field) {}
        }
    }

    func pickerCloseTapped(_ sender: UIBarButtonItem) {
        activeField?.resignFirstResponder()
    }

    func updateProfile() {
        let validationResult = heightTextField.validate()
            .merge(with: weightTextField.validate())

        switch validationResult {
        case .valid:
            updateAction.execute(saveButton)
        case .invalid(let errors):
            hanldeValidationError(errors)
        }
    }

    func backButtonTapped(_ sender: Any) {
        switch scene {
        case .phrase: break
        case .gender: scene = .phrase
        case .birthday: scene = .gender
        case .height: scene = .birthday
        case .weight: scene = .height
        case .origin: scene = .weight
        case .language: scene = .origin
        case .interests: scene = .language
        }
    }

    func nextButtonTapped(_ sender: Any) {
        if let activeField = activeField {
            switch activeField {
            case heightTextField, weightTextField:
                if !validate(activeField) {
                    return
                }
            default:
                break
            }
        }
        showNextScene()
    }

    // MARK: - UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        log.debug("Text editing")
        activeField = textField

        switch textField {
        case phraseTextField: scene = .phrase
        case genderTextField: scene = .gender
        case birthdayTextField: scene = .birthday
        case heightTextField: scene = .height
        case weightTextField: scene = .weight
        case originTextField: scene = .origin
        case languageTextField: scene = .language
        case interestsTextField: scene = .interests
        default: break
        }

        if textField == phraseTextField {

            if let len = phraseTextField.text?.characters.count,
                len < 2 {
                textField.text = "".addQuotes()
            }

            if let newPosition = textField.position(from: textField.endOfDocument, offset: -1) {

                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == phraseTextField,
            let len = phraseTextField.text?.characters.count,
            len == 2 {
            textField.text = ""
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        switch textField {
        case heightTextField,
             weightTextField:
            if !validate(textField) {
                return false
            }
        default:
            break
        }
        showNextScene()
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField != phraseTextField {
            return true
        }

        guard let textLen = textField.text?.characters.count else {
            return true
        }

        let prefixIntersection = NSIntersectionRange(NSMakeRange(0, 1), range)
        let postfixIntersection = NSIntersectionRange(NSMakeRange(textLen - 1, textLen), range)


        if prefixIntersection.length > 0 || postfixIntersection.length > 0 {
            return false
        }

        if range.location == 0 {
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: 1) {

                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
            return false
        }

        if range.location == textLen {
            if let newPosition = textField.position(from: textField.endOfDocument, offset: -1) {

                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
            return false
        }

        return true
    }

    // MARK: - KeyboardNotifications

    func keyboardWillShow(notification: Notification) {
        log.debug("keyboard will show")
        addKeyboardInsetAndScroll(scrollView: scrollView, activeField: activeField, notification: notification)
    }

    func keyboardWillHide(notification: Notification) {
        log.debug("keyboard will hide")
        removeKeyboardInset(scrollView: scrollView)
    }

    // MARK: - UIPickerDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.genders[row]?.displayValue
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        log.debug("picker view, selected row: \(row), gender: \(String(describing: viewModel.genders[row]))")
        viewModel.gender.value = viewModel.genders[row]
    }
    
    // MARK: - Validation
    func validate(_ field: UITextField) -> Bool {
        switch field.validate() {
        case .valid: return true
        case .invalid(let failureErrors):
            hanldeValidationError(failureErrors)
            return false
        }
    }

    func hanldeValidationError(_ errors: [Error]) {
        log.debug(errors)
        var msg = ""
        for error in errors {
            if !msg.isEmpty {
                msg += ". \n"
            }
            msg += error.localizedDescription
        }
        displayMessage(viewModel.viewTitle, msg)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if
            segue.identifier == profileToPhotoEditSegue,
            let viewController = segue.destination as? GZESignUpPhotoViewController {

            if let aSender = sender as? UIButton, aSender == saveButton {
                viewController.mode = .editGalleryPic
            } else {
                viewController.mode = .editProfilePic
            }
            viewController.viewModel = viewModel
        }
    }

    func showChooseModeController() {
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

    // MARK: - Scenes
    func setScene(_ newScene: Scene) {
        guard newScene != scene else { return }

        _scene = newScene

        switch scene {
        case .phrase: showPhraseScene()
        case .gender: showGenderScene()
        case .birthday: showBirthdayScene()
        case .height: showHeightScene()
        case .weight: showWeightScene()
        case .origin: showOriginScene()
        case .language: showLanguageScene()
        case .interests: showInterestsScene()
        }
        log.debug("scene changed to: \(scene)")
    }

    func showNextScene() {
        switch scene {
        case .phrase: scene = .gender
        case .gender: scene = .birthday
        case .birthday: scene = .height
        case .height: scene = .weight
        case .weight: scene = .origin
        case .origin: scene = .language
        case .language: scene = .interests
        case .interests: updateProfile()
        }
    }

    func showPhraseScene() {
        phraseTextField.isHidden = false
        phraseTextField.becomeFirstResponder()

        navigationItem.setLeftBarButton(nil, animated: true)
    }

    func showGenderScene() {
        genderTextField.isHidden = false
        genderTextField.becomeFirstResponder()

        navigationItem.setLeftBarButton(backButton, animated: true)
    }

    func showBirthdayScene() {
        birthdayTextField.isHidden = false
        birthdayTextField.becomeFirstResponder()

        navigationItem.setLeftBarButton(backButton, animated: true)
    }

    func showHeightScene() {
        heightTextField.isHidden = false
        heightTextField.becomeFirstResponder()
    }

    func showWeightScene() {
        weightTextField.isHidden = false
        weightTextField.becomeFirstResponder()

        navigationItem.setLeftBarButton(backButton, animated: true)
    }

    func showOriginScene() {
        originTextField.isHidden = false
        originTextField.becomeFirstResponder()

        navigationItem.setLeftBarButton(backButton, animated: true)
    }

    func showLanguageScene() {
        languageTextField.isHidden = false
        languageTextField.becomeFirstResponder()

        navigationItem.setLeftBarButton(backButton, animated: true)
    }

    func showInterestsScene() {
        interestsTextField.isHidden = false
        interestsTextField.becomeFirstResponder()

        navigationItem.setLeftBarButton(backButton, animated: true)
    }


    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }

}
