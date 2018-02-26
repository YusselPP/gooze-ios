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

    var viewModel: GZESignUpViewModel! = GZESignUpViewModel(GZEUserApiRepository())

    var updateAction: CocoaAction<UIButton>!

    var activeField: UITextField?

    var lastOrientation: UIDeviceOrientation!

    @IBOutlet weak var scrollView: UIScrollView!

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
    @IBOutlet weak var saveButton: UIButton!

    let birthdayPicker = UIDatePicker()
    let genderPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        lastOrientation = UIDevice.current.orientation


        setTextFieldFormat(phraseTextField, placeholder:  viewModel.phraseLabelText.addQuotes() )
        setTextFieldFormat(genderTextField, placeholder: viewModel.genderLabelText)
        setTextFieldFormat(birthdayTextField, placeholder: viewModel.birthdayLabelText)
        setTextFieldFormat(heightTextField, placeholder: viewModel.heightLabelText)
        setTextFieldFormat(weightTextField, placeholder: viewModel.weightLabelText)
        setTextFieldFormat(originTextField, placeholder: viewModel.originLabelText)
        setTextFieldFormat(languageTextField, placeholder: viewModel.languageLabelText)
        setTextFieldFormat(interestsTextField, placeholder: viewModel.interestsLabelText)

        phraseTextField.isHidden = false
        interestsTextField.returnKeyType = .done

        usernameLabel.reactive.text <~ viewModel.username.map { $0?.uppercased() }

        // viewModel.gender <~ genderTextField.reactive.continuousTextValues
        genderTextField.reactive.text <~ viewModel.gender.map { $0?.displayValue }
        viewModel.weight <~ weightTextField.reactive.continuousTextValues
        viewModel.height <~ heightTextField.reactive.continuousTextValues
        viewModel.origin <~ originTextField.reactive.continuousTextValues
        viewModel.phrase <~ phraseTextField.reactive.continuousTextValues
        viewModel.languages <~ languageTextField.reactive.continuousTextValues
        viewModel.interestedIn <~ interestsTextField.reactive.continuousTextValues

        profileImageView.reactive.image <~ viewModel.profilePic

        birthdayTextField.reactive.text <~ birthdayPicker.reactive.dates.map { [weak self] in
            self?.viewModel.birthday.value = $0
            return GZEDateHelper.dateFormatter.string(from: $0)
        }

        birthdayPicker.datePickerMode = .date
        birthdayPicker.maximumDate = Date()
        birthdayTextField.inputView = birthdayPicker


        genderPicker.dataSource = viewModel
        genderPicker.delegate = self
        genderTextField.inputView = genderPicker

        
        let toolBar = GZEPickerUIToolbar()
        toolBar.onDone = pickerDoneTapped
        toolBar.onClose = pickerCloseTapped

        genderTextField.inputAccessoryView = toolBar
        birthdayTextField.inputAccessoryView = toolBar

        // TODO: Validate numbers
        // TODO: validate interests

        updateAction = CocoaAction(viewModel.updateAction)
        { [weak self] _ in
            self?.showLoading()
        }

        viewModel.updateAction.values.observeValues(onupdateSuccess)
        viewModel.updateAction.errors.observeValues(onupdateError)
        saveButton.addTarget(self, action: #selector(updateProfile), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerForKeyboarNotifications(
            observer: self,
            willShowSelector: #selector(keyboardWillShow(notification:)),
            willHideSelector: #selector(keyboardWillHide(notification:))
        )
        //NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        // profileImageView.image = viewModel.photos.first?.value?.image

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications(observer: self)
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        log.debug("View Will Transition to size: \(size)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        log.debug("didLayoutSubviews")
        deviceRotated()
    }

    func deviceRotated(){
        var contentRect = CGRect.zero

        for view in scrollView.subviews {
            contentRect = contentRect.union(view.frame)
        }
        log.debug(scrollView.contentSize)
        scrollView.contentSize = contentRect.size
        log.debug(scrollView.contentSize)
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

    func updateProfile() {
        updateAction.execute(saveButton)
    }

    func onupdateSuccess(user: GZEUser) {
        hideLoading()
        // displayMessage(viewModel.viewTitle, "Perfil actualizado")
        performSegue(withIdentifier: profileToPhotoEditSegue, sender: saveButton)
    }

    func onupdateError(error: GZEError) {
        hideLoading()
        displayMessage(viewModel.viewTitle, error.localizedDescription)
    }

    // MARK: - UIActions

    @IBAction func editPhotoTapped(_ sender: Any) {
        performSegue(withIdentifier: profileToPhotoEditSegue, sender: nil)
    }

    func pickerDoneTapped(_ sender: UIBarButtonItem) {
        if let field = activeField {
            textFieldShouldReturn(field)
        }
    }

    func pickerCloseTapped(_ sender: UIBarButtonItem) {
        activeField?.resignFirstResponder()
    }

    // MARK: Scenes

    // MARK: UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        log.debug("Text editing")
        activeField = textField

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
        case phraseTextField:
            genderTextField.isHidden = false
            genderTextField.becomeFirstResponder()
        case genderTextField:
            birthdayTextField.isHidden = false
            birthdayTextField.becomeFirstResponder()
        case birthdayTextField:
            heightTextField.isHidden = false
            heightTextField.becomeFirstResponder()
        case heightTextField:
            weightTextField.isHidden = false
            weightTextField.becomeFirstResponder()
        case weightTextField:
            originTextField.isHidden = false
            originTextField.becomeFirstResponder()
        case originTextField:
            languageTextField.isHidden = false
            languageTextField.becomeFirstResponder()
        case languageTextField:
            interestsTextField.isHidden = false
            interestsTextField.becomeFirstResponder()
        case interestsTextField:
            updateProfile()
            return true
        default:
            return true
        }

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

    // MARK: KeyboardNotifications

    func keyboardWillShow(notification: Notification) {
        log.debug("keyboard will show")
        addKeyboardInsetAndScroll(scrollView: scrollView, activeField: activeField, notification: notification)
    }

    func keyboardWillHide(notification: Notification) {
        log.debug("keyboard will hide")
        removeKeyboardInset(scrollView: scrollView)
    }

    // MARK: UIPickerDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.genders[row]?.displayValue
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        log.debug("picker view, selected row: \(row), gender: \(String(describing: viewModel.genders[row]))")
        viewModel.gender.value = viewModel.genders[row]
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

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }

}
