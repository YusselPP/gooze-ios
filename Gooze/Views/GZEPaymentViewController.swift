//
//  GZEPaymentViewController.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/20/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZEPaymentViewController: UIViewController {

    var viewModel: GZEPaymentViewModel!

    let backButton = GZEBackUIBarButtonItem()
    
    @IBOutlet weak var bottomButton: GZEButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("\(self) init")
        self.setupInterfaceObjects()
        self.setupBindings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupInterfaceObjects() {
        self.backButton.onButtonTapped = {[weak self] _ in
            self?.previousController(animated: true)
        }
        self.navigationItem.setLeftBarButton(self.backButton, animated: false)

        self.bottomButton.setGrayFormat()
    }
    
    private func setupBindings() {
        self.viewModel.dismissSignal.observeValues{[weak self] in
            self?.previousController(animated: true)
        }

        // actions
        self.bottomButton.reactive.pressed = self.viewModel.bottomButtonCocoaAction
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    deinit {
        log.debug("\(self) disposed")
    }

}
