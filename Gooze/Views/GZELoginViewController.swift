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

    

    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
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

        viewModel.loginAction.values.observeValues({ _ in

            SwiftOverlays.removeAllBlockingOverlays()
            self.performSegue(withIdentifier: self.viewModel.loginSegueId, sender: nil)
        })

        viewModel.loginAction.errors.observeValues { err in

            SwiftOverlays.removeAllBlockingOverlays()
            self.displayMessage(self.viewModel.viewTitle, err.localizedDescription)
        }
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
        if segue.identifier == viewModel.loginSegueId,
            let navController = segue.destination as? UINavigationController,
            let searchGoozeController = navController.viewControllers.first as? GZESearchGoozeViewController {

            searchGoozeController.viewModel = viewModel.getSearchGoozeViewModel()
        }
    }

    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        log.debug("unwindToLogin")
    }

    func displayMessage(_ title: String, _ message: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: viewModel.displayOkTitle, style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true)
    }
}
