//
//  GZELoginViewController.swift
//  Gooze
//
//  Created by Yussel on 10/21/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZELoginViewController: UIViewController {

    var viewModel: GZELoginViewModel!

    var loginSuccesObserver: Disposable?
    var loginErrorObserver: Disposable?

    let signUpSegueId = "signUpSegue"

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        // Button titles
        loginButton.setTitle(viewModel.loginButtonTitle, for: .normal)
        signUpButton.setTitle(viewModel.signUpButtonTitle, for: .normal)
        forgotPasswordButton.setTitle(viewModel.forgotPasswordButtonTitle, for: .normal)


        // Bindings
        viewModel.email <~ emailTextField.reactive.continuousTextValues
        viewModel.password <~ passwordTextField.reactive.continuousTextValues

        loginButton.reactive.pressed = CocoaAction(viewModel.loginAction) {
            [weak self] _ in

            self?.showLoading()
        }

        loginSuccesObserver = viewModel.loginAction.values.observeValues(onLogin)

        loginErrorObserver = viewModel.loginAction.errors.observeValues(onLoginError)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Hide navigation bar
        if let navBarController = self.navigationController {
            navBarController.setNavigationBarHidden(true, animated: false)
        }

    }

    override func viewDidDisappear(_ animated: Bool) {
        // Show navigation bar
        if let navBarController = self.navigationController {
            navBarController.setNavigationBarHidden(false, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func onLogin(user: GZEAccesToken) -> Void {

        hideLoading()
        
        if
            let navController = storyboard?.instantiateViewController(withIdentifier: "SearchGoozeNavController") as? UINavigationController,
            let viewController = navController.viewControllers.first as? GZESearchGoozeViewController {

            loginSuccesObserver?.dispose()
            loginErrorObserver?.dispose()
            viewController.viewModel = GZESearchGoozeViewModel()

            setRootController(controller: navController)
        } else {
            log.error("Unable to instantiate SearchGoozeNavController")
            displayMessage(viewModel.viewTitle, GZERepositoryError.UnexpectedError.localizedDescription)
        }
    }

    func onLoginError(err: GZEError) {
        hideLoading()
        displayMessage(viewModel.viewTitle, err.localizedDescription)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if
            segue.identifier == signUpSegueId,
            let viewController = segue.destination as? GZESignUpBasicViewController {

            viewController.viewModel = viewModel.getSignUpViewModel()
        }
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
