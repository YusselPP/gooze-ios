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

        viewModel.checkAuth(self)
        viewModel.loadUserAction.events.observeValues { [weak self] in
            switch $0 {
            case .value: self?.login()
            case .completed: break
            default: self?.showLogin()
            }
        }
    }

    func login() {
        super.login(userRepository: viewModel.userRepository)
    }

    func showLogin() {
        super.showLoginView(userRepository: viewModel.userRepository)
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

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
