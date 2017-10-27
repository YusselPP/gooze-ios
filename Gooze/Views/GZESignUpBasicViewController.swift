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

class GZESignUpBasicViewController: UIViewController {

    var viewModel: GZESignUpViewModel!

    let basicToMoreSignUpSegueId = "basicToMoreSignUpSegue"

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")
        // Do any additional setup after loading the view.
        viewModel.username <~ usernameTextField.reactive.continuousTextValues
        viewModel.email <~ emailTextField.reactive.continuousTextValues
        let x = viewModel.password <~ passwordTextField.reactive.continuousTextValues
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
