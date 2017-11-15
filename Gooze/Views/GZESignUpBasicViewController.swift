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

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var usernameFeedbackLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")
        // Do any additional setup after loading the view.
        viewModel.username <~ usernameTextField.reactive.continuousTextValues
        viewModel.email <~ emailTextField.reactive.continuousTextValues
        viewModel.password <~ passwordTextField.reactive.continuousTextValues

        usernameTextField.validationRules = GZESignUpViewModel.validationRule.username.stringRules
        usernameTextField.validationHandler = { [weak self] result in
            switch result {
            case .valid:
                self?.usernameFeedbackLabel.text = nil
            case .invalid(let failureErrors):
                log.debug(failureErrors)
                self?.usernameFeedbackLabel.textColor = .red
                self?.usernameFeedbackLabel.text = failureErrors.first?.localizedDescription
            }
        }
        usernameTextField.validateOnEditingEnd(enabled: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

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


    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
