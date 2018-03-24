//
//  GZELoadingViewController.swift
//  Gooze
//
//  Created by Yussel on 3/21/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZELoadingViewController: UIViewController {

    var viewModel: GZELoadingViewModel!

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("\(self) init")

        // Wait until next tick for view to be loaded, if not it will try to present
        // login view controller over app loading screen and it will fail
        Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(checkAuth), userInfo: nil, repeats: false)
    }

    func checkAuth() {
        viewModel.loginStoredUser {[weak self] _ in
            guard let this = self else {
                log.error("GZELoadingViewController disposed before being used")
                return
            }
            this.viewModel.checkAuth(presenter: this) { _ in
                this.showInitialController()
            }
        }
    }

    func showInitialController() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        if
            let navController = mainStoryboard.instantiateViewController(withIdentifier: "SearchGoozeNavController") as? UINavigationController,
            let chooseModeController = navController.viewControllers.first as? GZEChooseModeViewController {

            // Set up initial view model
            chooseModeController.viewModel = GZEChooseModeViewModel(self.viewModel.userRepository)
            setRootController(controller: navController)
        } else {
            log.error("Unable to instantiate SearchGoozeNavController")
            displayMessage("Unexpected error", "Please contact support")
        }
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

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
