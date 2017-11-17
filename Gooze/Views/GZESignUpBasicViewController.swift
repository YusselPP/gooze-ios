//
//  GZESignUpBasicViewController.swift
//  Gooze
//
//  Created by Yussel Paredes on 10/26/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Validator

class GZESignUpBasicViewController: UIViewController {

    var viewModel: GZESignUpViewModel!

    let basicToMoreSignUpSegueId = "basicToMoreSignUpSegue"

    @IBOutlet weak var usernameTextField: GZETextField!
    @IBOutlet weak var emailTextField: GZETextField!
    @IBOutlet weak var passwordTextField: GZETextField!

    @IBOutlet weak var usernameFeedbackLabel: UILabel!
    @IBOutlet weak var emailFeedbackLabel: UILabel!
    @IBOutlet weak var passwordFeedbackLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        // nextButton.reactive.isEnabled <~ viewModel.isBasicNextButtonEnabled

        usernameTextField.model = viewModel.username
        usernameTextField.validationRules = GZESignUpViewModel.validationRule.username.stringRules
        usernameTextField.validationFeedbackLabel = usernameFeedbackLabel
        // usernameTextField.validateOnEditingEnd(enabled: true)

        emailTextField.model = viewModel.email
        emailTextField.validationRules = GZESignUpViewModel.validationRule.email.stringRules
        emailTextField.validationFeedbackLabel = emailFeedbackLabel
        //emailTextField.validateOnEditingEnd(enabled: true)

        passwordTextField.model = viewModel.password
        passwordTextField.validationRules = GZESignUpViewModel.validationRule.password.stringRules
        passwordTextField.validationFeedbackLabel = passwordFeedbackLabel
        // passwordTextField.validateOnEditingEnd(enabled: true)

        usernameTextField.isValid.producer
            .and(emailTextField.isValid.producer)
            .and(passwordTextField.isValid.producer)
            .startWithValues { [weak self] val in

            self?.viewModel.isBasicNextButtonEnabled.value = val
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == basicToMoreSignUpSegueId {
            validate()
            return viewModel.isBasicNextButtonEnabled.value
        }
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if
            segue.identifier == basicToMoreSignUpSegueId,
            let viewController = segue.destination as? GZESignUpMoreViewController {

            viewController.viewModel = viewModel
        }
    }

    func validate() {
        usernameTextField.validate()
        emailTextField.validate()
        passwordTextField.validate()
    }


    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
