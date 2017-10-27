//
//  GZESearchGoozeViewController.swift
//  Gooze
//
//  Created by Yussel Paredes on 10/25/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

class GZESearchGoozeViewController: UIViewController {

    var viewModel: GZESearchGoozeViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {

        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if
            let navController = mainStoryboard.instantiateViewController(withIdentifier: "LoginNavController") as? UINavigationController,
            let loginController = navController.viewControllers.first as? GZELoginViewController {

            // Set up initial view model
            loginController.viewModel = GZELoginViewModel(GZEUserApiRepository())
            setRootController(controller: navController)
        } else {
            log.error("Unable to instantiate InitialViewController")
            displayMessage("Unexpected error", "Please contact support")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func unwindToSearchGooze(segue: UIStoryboardSegue) {
        log.debug("unwindToSearchGooze")
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
