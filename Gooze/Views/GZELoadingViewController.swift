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

    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("\(self) init")
        
        GZEConstants.horizontalSize = traitCollection.horizontalSizeClass
        GZEConstants.verticalSize = traitCollection.verticalSizeClass

        log.debug("horizontalSize: \(GZEConstants.horizontalSize)")

        // Wait until next tick for view to be loaded, if not it will try to present
        // login view controller over app loading screen and it will fail
        Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(checkAuth), userInfo: nil, repeats: false)
    }

    func checkAuth() {
        viewModel.loginStoredUser {[weak self] _ in
            log.debug("login stored user completed")
            guard let this = self else {
                log.error("GZELoadingViewController disposed before being used")
                return
            }
            this.viewModel.checkAuth(presenter: this) { _ in
                log.debug("check auth completed")
                this.showInitialController()
            }
        }
    }

    func showInitialController() {
        log.debug("Trying to show initiall controller...")
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        if
            let navController = mainStoryboard.instantiateViewController(withIdentifier: "SearchGoozeNavController") as? UINavigationController,
            let chooseModeController = navController.viewControllers.first as? GZEChooseModeViewController {

            log.debug("Initial controller instantiated. Setting up its view model")
            // Set up initial view model
            chooseModeController.viewModel = GZEChooseModeViewModel(self.viewModel.userRepository)
            setRootController(controller: navController)
        } else {
            log.error("Unable to instantiate SearchGoozeNavController")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
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
