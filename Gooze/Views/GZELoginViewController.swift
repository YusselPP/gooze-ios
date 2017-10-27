//
//  GZELoginViewController.swift
//  Gooze
//
//  Created by Yussel on 10/21/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import Localize_Swift
import ReactiveSwift
import ReactiveCocoa
import SwiftOverlays


class GZELoginViewController: UIViewController {

    var viewModel: GZELoginViewModel!

    var loginSuccesObserver: Disposable?
    var loginErrorObserver: Disposable?

    let signUpSegueId = "signUpSegue"

    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")
        // Do any additional setup after loading the view.

        // Button titles
        loginButton.setTitle(viewModel.loginButtonTitle, for: .normal)
        signUpButton.setTitle(viewModel.signUpButtonTitle, for: .normal)


        // Bindings
        viewModel.username <~ emailTextField.reactive.continuousTextValues
        viewModel.password <~ passwordTextField.reactive.continuousTextValues

        loginButton.reactive.pressed = CocoaAction(viewModel.loginAction) { _ in
            SwiftOverlays.showBlockingWaitOverlay()
        }

        loginSuccesObserver = viewModel.loginAction.values.observeValues(onLogin)

        loginErrorObserver = viewModel.loginAction.errors.observeValues {[weak self] err in

            SwiftOverlays.removeAllBlockingOverlays()
            guard let strongSelf = self else { return }
            strongSelf.displayMessage(strongSelf.viewModel.viewTitle, err.localizedDescription)
        }
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

    func onLogin(user: GZEUser) -> Void {

        SwiftOverlays.removeAllBlockingOverlays()

        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if
            let navController = mainStoryboard.instantiateViewController(withIdentifier: "SearchGoozeNavController") as? UINavigationController,
            let viewController = navController.viewControllers.first as? GZESearchGoozeViewController {

            loginSuccesObserver?.dispose()
            loginErrorObserver?.dispose()
            viewController.viewModel = GZESearchGoozeViewModel()

            setRootController(controller: navController)
        } else {
            log.error("Unable to instantiate SearchGoozeNavController")
            displayMessage("Unexpected error", "Please contact support")
        }
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
