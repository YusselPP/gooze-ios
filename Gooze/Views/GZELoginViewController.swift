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

struct User {
    let name: MutableProperty<String?>
}

class GZELoginViewController: UIViewController {

    var loginViewModel: GZELoginViewModel!
    var user = User(name: MutableProperty(""))

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loginViewModel.username <~ usernameTextField.reactive.continuousTextValues
        loginViewModel.password <~ passwordTextField.reactive.continuousTextValues
        infoLabel.reactive.text <~ loginViewModel.errorMessage
        loginButton.reactive.pressed = CocoaAction(loginViewModel.postAction)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
