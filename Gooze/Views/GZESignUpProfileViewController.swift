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

class GZESignUpProfileViewController: UIViewController, UITextFieldDelegate {

    var viewModel: GZESignUpViewModel!

    var saveAction: CocoaAction<UIButton>!

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

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        lastOrientation = UIDevice.current.orientation

        phraseTextField.delegate = self
        genderTextField.delegate = self
        birthdayTextField.delegate = self
        heightTextField.delegate = self
        weightTextField.delegate = self
        originTextField.delegate = self
        languageTextField.delegate = self
        interestsTextField.delegate = self

        usernameLabel.reactive.text <~ viewModel.username.map { $0?.uppercased() }

        setTextFieldFormat(phraseTextField, placeholder: viewModel.phraseLabelText)
        setTextFieldFormat(genderTextField, placeholder: viewModel.genderLabelText)
        setTextFieldFormat(birthdayTextField, placeholder: viewModel.birthdayLabelText)
        setTextFieldFormat(heightTextField, placeholder: viewModel.heightLabelText)
        setTextFieldFormat(weightTextField, placeholder: viewModel.weightLabelText)
        setTextFieldFormat(originTextField, placeholder: viewModel.originLabelText)
        setTextFieldFormat(languageTextField, placeholder: viewModel.languageLabelText)
        setTextFieldFormat(interestsTextField, placeholder: viewModel.interestsLabelText)

        saveAction = CocoaAction(viewModel.saveAction)
        { [weak self] _ in
            self?.showLoading()
        }


    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerForKeyboarNotifications(
            observer: self,
            willShowSelector: #selector(keyboardWillShow(notification:)),
            willHideSelector: #selector(keyboardWillHide(notification:))
        )
        //NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications(observer: self)
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

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
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = .none
        textField.textColor = UIColor.white
        textField.textAlignment = .center
        textField.font = UIFont(name: "HelveticaNeue", size: 17)!
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 17)!])
    }

    // MARK: UITextFieldDelegate

    func textFieldDidBeginEditing(_ textField: UITextField) {
        log.debug("Text editing")
        activeField = textField
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

    // MARK: - Scenes

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }

}
