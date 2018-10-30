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
import Validator

class GZESignUpProfileViewController: UIViewController, UITextFieldDelegate, GZEDismissVCDelegate {

    let profileToPhotoEditSegue = "profileToPhotoEditSegue"
    let segueToSearchGenderPicker = "segueToSearchGenderPicker"

    var viewModel: GZEUpdateProfileViewModel!

    var updateAction: CocoaAction<UIButton>!

    var activeField: UITextField?

    enum Scene {
        case profilePic
        case profilePicSet
        case phrase
        case gender
        case birthday
        case height
        case weight
        case origin
        case language
        case interests
        case searchFor
        case editProfile
    }
    var _scene: Scene = .profilePic
    var scene: Scene {
        get { return _scene }
        set(newScene){ setScene(newScene) }
    }

    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var bottomReferenceView: UIView!

    @IBOutlet weak var usernameContainer: UIView!
    @IBOutlet weak var usernameLabel: GZELabel!

    @IBOutlet weak var phraseTopLine: UIView!
    @IBOutlet weak var phraseBotLine: UIView!
    @IBOutlet weak var phraseTextField: GZETextField!
    @IBOutlet weak var genderTextField: GZETextField!
    @IBOutlet weak var birthdayTextField: GZETextField!
    @IBOutlet weak var heightTextField: GZETextField!
    @IBOutlet weak var weightTextField: GZETextField!
    @IBOutlet weak var originTextField: GZETextField!
    @IBOutlet weak var languageTextField: GZETextField!
    @IBOutlet weak var interestsTextField: GZETextField!

    @IBOutlet weak var searchForGenderLabel: GZELabel!
    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var viewBottomSpaceConstraint: NSLayoutConstraint!

    let birthdayPicker = UIDatePicker()
    let genderPicker = UIPickerView()
    let heightPicker = UIPickerView()
    let weightPicker = UIPickerView()
    let interestsPicker = UIPickerView()

    let backButton = GZEBackUIBarButtonItem()
    let nextButton = GZENextUIBarButtonItem()

    var serachForGenderGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        setupInterfaceObjects()
        setupBindings()
        setupActions()

        showProfilePicScene()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerForKeyboarNotifications(
            observer: self,
            willShowSelector: #selector(keyboardWillShow(notification:)),
            willHideSelector: #selector(keyboardWillHide(notification:))
        )
        if scene == .profilePic && profileImageView.image != nil {
            scene = .profilePicSet
        }
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

        usernameLabel.setWhiteFontFormat()

        phraseTextField.autocapitalizationType = .sentences
        originTextField.autocapitalizationType = .words
        languageTextField.autocapitalizationType = .words
        setTextFieldFormat(phraseTextField, placeholder:  viewModel.phraseLabelText.addQuotes() )
        setTextFieldFormat(genderTextField, placeholder: viewModel.genderLabelText)
        setTextFieldFormat(birthdayTextField, placeholder: viewModel.birthdayLabelText)
        setTextFieldFormat(heightTextField, placeholder: viewModel.heightLabelText)
        setTextFieldFormat(weightTextField, placeholder: viewModel.weightLabelText)
        setTextFieldFormat(originTextField, placeholder: viewModel.originLabelText)
        setTextFieldFormat(languageTextField, placeholder: viewModel.languageLabelText)
        setTextFieldFormat(interestsTextField, placeholder: viewModel.interestsLabelText)

        searchForGenderLabel.setWhiteFontFormat()
        serachForGenderGesture = UITapGestureRecognizer(target: self, action: #selector(searchForGenderTapped))
        searchForGenderLabel.addGestureRecognizer(serachForGenderGesture)
        // heightTextField.validationRules = GZEUser.Validation.height.stringRule()
        // weightTextField.validationRules = GZEUser.Validation.weight.stringRule()

        let toolBar = GZEPickerUIToolbar()
        toolBar.onDone = ptr(self, GZESignUpProfileViewController.pickerDoneTapped)
        toolBar.onClose = ptr(self, GZESignUpProfileViewController.pickerCloseTapped)
        if scene == .editProfile {
            toolBar.rightButtonTitle = .doneButtonTitle
        }

        birthdayPicker.datePickerMode = .date
        birthdayPicker.maximumDate = Date()
        birthdayTextField.inputView = birthdayPicker
        birthdayTextField.inputAccessoryView = toolBar
        birthdayPicker.date = viewModel.birthday.map{$0 == nil ? Date() : $0!}.value

        genderPicker.dataSource = viewModel.genderPickerDatasource
        genderPicker.delegate = viewModel.genderPickerDelegate
        genderTextField.inputView = genderPicker
        genderTextField.inputAccessoryView = toolBar
        if let selectedPos = viewModel.genderPickerDelegate.getSelectedElementPos(inComponent: 0) {
            genderPicker.selectRow(selectedPos, inComponent: 0, animated: false)
        }

        heightPicker.dataSource = viewModel.heightPickerDatasource
        heightPicker.delegate = viewModel.heightPickerDelegate
        heightTextField.inputView = heightPicker
        heightTextField.inputAccessoryView = toolBar
        for num in 0..<heightPicker.numberOfComponents {
            if let selectedPos = viewModel.heightPickerDelegate.getSelectedElementPos(inComponent: num) {
                heightPicker.selectRow(selectedPos, inComponent: num, animated: false)
            }
        }

        weightPicker.dataSource = viewModel.weightPickerDatasource
        weightPicker.delegate = viewModel.weightPickerDelegate
        weightTextField.inputView = weightPicker
        weightTextField.inputAccessoryView = toolBar
        for num in 0..<weightPicker.numberOfComponents {
            if let selectedPos = viewModel.weightPickerDelegate.getSelectedElementPos(inComponent: num) {
                weightPicker.selectRow(selectedPos, inComponent: num, animated: false)
            }
        }

        interestsPicker.dataSource = viewModel.interestPickerDatasource
        interestsPicker.delegate = viewModel.interestPickerDelegate
        interestsTextField.inputView = interestsPicker
        interestsTextField.inputAccessoryView = toolBar
        for num in 0..<interestsPicker.numberOfComponents {
            if let selectedPos = viewModel.interestPickerDelegate.getSelectedElementPos(inComponent: num) {
                interestsPicker.selectRow(selectedPos, inComponent: num, animated: false)
            }
        }
    }

    func setupBindings() {
        // Out bindings
        usernameLabel.reactive.text <~ viewModel.username.map { username -> String? in
            return username?.uppercased()
        }

        profileImageView.reactive.noirImageUrlRequestLoading <~ viewModel.profilePicRequest
        phraseTextField.reactive.text <~ viewModel.phrase
        genderTextField.reactive.text <~ viewModel.gender.map { $0?.displayValue }
        searchForGenderLabel.reactive.text <~ viewModel.searchForGenderLabel
        birthdayTextField.reactive.text <~ viewModel.birthday.map {
            $0.flatMap { GZEDateHelper.displayDateFormatter.string(from: $0) }
        }
        heightTextField.reactive.text <~ viewModel.height.map{ height -> String? in
            if height == nil || height!.isEmpty || height == "0.00" {
                return ""
            } else {
                return "\(height ?? "") \(GZEUser.heightUnit)"
            }
        }
        weightTextField.reactive.text <~ viewModel.weight.map{ weight -> String? in
            if weight == nil || weight!.isEmpty || weight == "0" {
                return ""
            } else {
                return "\(weight ?? "") \(GZEUser.weightUnit)"
            }
        }
        originTextField.reactive.text <~ viewModel.origin
        languageTextField.reactive.text <~ viewModel.languages
        interestsTextField.reactive.text <~ viewModel.interestedIn.map{$0?.localized()}

        // In bindings
        viewModel.phrase <~ phraseTextField.reactive.continuousTextValues
        // viewModel.gender binding set in viewModel
        viewModel.birthday <~ birthdayPicker.reactive.dates.map{[weak self] date -> (Date?) in

            let rule = ValidationRuleCondition<Date>(
                error: GZEValidationError.underAge,
                condition: {
                    if let date = $0 {
                        return GZEDateHelper.years(from: date, to: Date()) >= 18
                    } else {
                        return true
                    }
                }
            )
            var validationRuleSet = ValidationRuleSet<Date>()
            validationRuleSet.add(rule: rule)

            switch date.validate(rules: validationRuleSet) {
            case .valid: return date
            case .invalid(let errors):
                self?.hanldeValidationError(errors)
                return nil
            }
        }
        // viewModel.height <~ heightTextField.reactive.continuousTextValues
        // viewModel.weight <~ weightTextField.reactive.continuousTextValues
        viewModel.origin <~ originTextField.reactive.continuousTextValues
        viewModel.languages <~ languageTextField.reactive.continuousTextValues
        //viewModel.interestedIn <~ interestsTextField.reactive.continuousTextValues


        skipButton.reactive.isHidden <~ viewModel.skipButtonIsHidden
        phraseTextField.reactive.isHidden <~ viewModel.phraseTextFieldIsHidden
        phraseTopLine.reactive.isHidden <~ viewModel.phraseTopLineIsHidden
        phraseBotLine.reactive.isHidden <~ viewModel.phraseBotLineIsHidden
        genderTextField.reactive.isHidden <~ viewModel.genderTextFieldIsHidden
        birthdayTextField.reactive.isHidden <~ viewModel.birthdayTextFieldIsHidden
        heightTextField.reactive.isHidden <~ viewModel.heightTextFieldIsHidden
        weightTextField.reactive.isHidden <~ viewModel.weightTextFieldIsHidden
        originTextField.reactive.isHidden <~ viewModel.originTextFieldIsHidden
        languageTextField.reactive.isHidden <~ viewModel.languageTextFieldIsHidden
        interestsTextField.reactive.isHidden <~ viewModel.interestsTextFieldIsHidden
        searchForGenderLabel.reactive.isHidden <~ viewModel.searchForGenderLabelIsHidden

        viewModel.navigationRightButton.producer.startWithValues {[weak self] in
            self?.navigationItem.rightBarButtonItem = $0
        }
    }

    func setupActions() {
        backButton.onButtonTapped = ptr(self, GZESignUpProfileViewController.backButtonTapped)
        nextButton.onButtonTapped = ptr(self, GZESignUpProfileViewController.nextButtonTapped)
        saveButton.addTarget(self, action: #selector(updateProfile), for: .touchUpInside)
        
        updateAction = CocoaAction(viewModel.updateAction)
        { [weak self] _ in
            self?.showLoading()
        }
        viewModel.updateAction.events.observeValues { [weak self] evt in
            self?.onEvent(event: evt)
        }
    }

    func setTextFieldFormat(_ textField: UITextField, placeholder: String) {
        textField.delegate = self

        if scene == .editProfile {
            textField.returnKeyType = .done
        } else {
            textField.returnKeyType = .next
        }

        textField.backgroundColor = UIColor.clear
        textField.borderStyle = .none
        textField.textColor = UIColor.white
        textField.textAlignment = .center
        textField.font = GZEConstants.Font.main
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: GZEConstants.Font.main])
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
        if scene == .editProfile {
            previousController(animated: true)
        } else {
            performSegue(withIdentifier: profileToPhotoEditSegue, sender: saveButton)
        }
    }

    func onError(_ error: GZEError) {
        GZEAlertService.shared.showBottomAlert(text: error.localizedDescription)
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
            if textFieldShouldReturn(field) {
                field.resignFirstResponder()
            }
        }
    }

    func pickerCloseTapped(_ sender: UIBarButtonItem) {
        activeField?.resignFirstResponder()
    }

    func searchForGenderTapped() {
        performSegue(withIdentifier: segueToSearchGenderPicker, sender: nil)
    }

    func updateProfile() {
        //let validationResult = heightTextField.validate()
        //    .merge(with: weightTextField.validate())

        //switch validationResult {
        //case .valid:
            updateAction.execute(saveButton)
        //case .invalid(let errors):
        //    hanldeValidationError(errors)
        //}
    }

    func backButtonTapped(_ sender: Any) {
        switch scene {
        case .profilePic,
            .profilePicSet,
            .editProfile: previousController(animated: true)
        case .phrase: scene = .profilePicSet
        case .gender: scene = .phrase
        case .birthday: scene = .gender
        case .height: scene = .birthday
        case .weight: scene = .height
        case .origin: scene = .weight
        case .language: scene = .origin
        case .interests: scene = .language
        case .searchFor: scene = .interests
        }
    }

    func nextButtonTapped(_ sender: Any) {
//        if let activeField = activeField {
//            switch activeField {
//            case heightTextField, weightTextField:
//                if !validate(activeField) {
//                    return
//                }
//            default:
//                break
//            }
//        }
        showNextScene()
    }

    // MARK: - UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        log.debug("Text editing")
        activeField = textField

        if scene != .editProfile {
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

        //switch textField {
        //case heightTextField,
        //     weightTextField:
        //    if !validate(textField) {
         //       return false
         //   }
       // default:
        //    break
       // }

        if scene == .editProfile {
            return true
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
        resizeViewWithKeyboard(keyboardShow: true, constraint: viewBottomSpaceConstraint, notification: notification, view: self.view)
    }

    func keyboardWillHide(notification: Notification) {
        log.debug("keyboard will hide")
        resizeViewWithKeyboard(keyboardShow: false, constraint: viewBottomSpaceConstraint, notification: notification, view: self.view, safeInsets: false)
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
        GZEAlertService.shared.showBottomAlert(text: msg)
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
                let loginDismiss = viewModel.dismiss
                viewModel.dismiss = {[weak self] in
                    viewController.performSegue(withIdentifier: viewController.segueToPayment, sender: nil)
                    self?.viewModel.dismiss = loginDismiss
                }
            } else {
                viewController.mode = .editProfilePic
            }
            viewController.viewModel = viewModel
        } else if segue.identifier == segueToSearchGenderPicker {

            if let vc = segue.destination as? GZECheckListViewController {
                vc.dismissDelegate = self
                vc.viewModel = viewModel.genderCheckListVM
            } else {
                log.error("Segue with invalid destination view controller")
            }
        }
    }

    func showChooseModeController() {
        self.viewModel.dismiss?()
    }

    // MARK: - Scenes
    func setScene(_ newScene: Scene) {
        guard newScene != scene else { return }

        _scene = newScene

        GZEAlertService.shared.dismissBottomAlert()

        switch scene {
        case .profilePic: showProfilePicScene()
        case .profilePicSet: showProfilePicSetScene()
        case .phrase: showPhraseScene()
        case .gender: showGenderScene()
        case .birthday: showBirthdayScene()
        case .height: showHeightScene()
        case .weight: showWeightScene()
        case .origin: showOriginScene()
        case .language: showLanguageScene()
        case .interests: showInterestsScene()
        case .searchFor: showSearchForScene()
        case .editProfile: showEditProfileScene()
        }
        log.debug("scene changed to: \(scene)")
    }

    func showNextScene() {
        switch scene {
        case .profilePic: scene = .profilePicSet
        case .profilePicSet: scene = .phrase
        case .phrase: scene = .gender
        case .gender: scene = .birthday
        case .birthday: scene = .height
        case .height: scene = .weight
        case .weight: scene = .origin
        case .origin: scene = .language
        case .language: scene = .interests
        case .interests: scene = .searchFor
        case .searchFor: updateProfile()
        case .editProfile: updateProfile()
        }
    }

    func showProfilePicScene() {
        navigationItem.setLeftBarButton(backButton, animated: true)
        viewModel.navigationRightButton.value = nextButton
    }

    func showProfilePicSetScene() {
        viewModel.phraseTextFieldIsHidden.value = false
        viewModel.phraseTopLineIsHidden.value = false
        viewModel.phraseBotLineIsHidden.value = false
        phraseTextField.resignFirstResponder()
        navigationItem.setLeftBarButton(backButton, animated: true)
        viewModel.navigationRightButton.value = nextButton
    }

    func showPhraseScene() {
        viewModel.phraseTextFieldIsHidden.value = false
        viewModel.phraseTopLineIsHidden.value = false
        viewModel.phraseBotLineIsHidden.value = false
        phraseTextField.becomeFirstResponder()

        navigationItem.setLeftBarButton(backButton, animated: true)
        viewModel.navigationRightButton.value = nextButton
    }

    func showGenderScene() {
        viewModel.genderTextFieldIsHidden.value = false
        genderTextField.becomeFirstResponder()

        navigationItem.setLeftBarButton(backButton, animated: true)
        viewModel.navigationRightButton.value = nextButton
    }

    func showBirthdayScene() {
        viewModel.birthdayTextFieldIsHidden.value = false
        birthdayTextField.becomeFirstResponder()

        navigationItem.setLeftBarButton(backButton, animated: true)
        viewModel.navigationRightButton.value = nextButton
    }

    func showHeightScene() {
        viewModel.heightTextFieldIsHidden.value = false
        heightTextField.becomeFirstResponder()
        viewModel.navigationRightButton.value = nextButton
    }

    func showWeightScene() {
        viewModel.weightTextFieldIsHidden.value = false
        weightTextField.becomeFirstResponder()

        navigationItem.setLeftBarButton(backButton, animated: true)
        viewModel.navigationRightButton.value = nextButton
    }

    func showOriginScene() {
        viewModel.originTextFieldIsHidden.value = false
        originTextField.becomeFirstResponder()

        navigationItem.setLeftBarButton(backButton, animated: true)
        viewModel.navigationRightButton.value = nextButton
    }

    func showLanguageScene() {
        viewModel.languageTextFieldIsHidden.value = false
        languageTextField.becomeFirstResponder()

        navigationItem.setLeftBarButton(backButton, animated: true)
        viewModel.navigationRightButton.value = nextButton
    }

    func showInterestsScene() {
        viewModel.interestsTextFieldIsHidden.value = false
        interestsTextField.becomeFirstResponder()

        navigationItem.setLeftBarButton(backButton, animated: true)
        viewModel.navigationRightButton.value = nextButton
    }

    func showSearchForScene() {
        interestsTextField.resignFirstResponder()
        viewModel.searchForGenderLabelIsHidden.value = false
        navigationItem.setLeftBarButton(backButton, animated: true)
        viewModel.navigationRightButton.value = nextButton

        searchForGenderTapped()
    }

    func showEditProfileScene() {
        viewModel.skipButtonIsHidden.value = true

        viewModel.phraseTextFieldIsHidden.value = false
        viewModel.phraseTopLineIsHidden.value = false
        viewModel.phraseBotLineIsHidden.value = false
        viewModel.genderTextFieldIsHidden.value = false
        viewModel.birthdayTextFieldIsHidden.value = false
        viewModel.heightTextFieldIsHidden.value = false
        viewModel.weightTextFieldIsHidden.value = false
        viewModel.originTextFieldIsHidden.value = false
        viewModel.languageTextFieldIsHidden.value = false
        viewModel.interestsTextFieldIsHidden.value = false
        viewModel.searchForGenderLabelIsHidden.value = false

        viewModel.navigationRightButton.value = nil
    }

    // GZEDimissVCDelegate
    func onDismissTapped(_ vc: UIViewController) {
        if vc.isKind(of: GZECheckListViewController.self) {
            self.previousController(animated: true)
        } else {
            log.error("Invalid vc instance")
        }
    }


    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }

}
