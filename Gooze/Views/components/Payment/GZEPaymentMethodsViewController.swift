//
//  GZEPaymentMethodsViewController.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/14/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import BraintreeDropIn
import SwiftOverlays

class GZEPaymentMethodsViewController: UIViewController, GZEDismissVCDelegate {

    var viewModel: GZEPaymentMethodsViewModel!

    weak var dismissDelegate: GZEDismissVCDelegate?

    let backButton = GZEBackUIBarButtonItem()

    @IBOutlet weak var paymentsCollectionView: GZEPaymentCollectionView!
    @IBOutlet weak var bottomActionButton: GZEButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("\(self) init")

        setupInterfaceObjects()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.viewShownObs.send(value: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewModel.viewShownObs.send(value: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupInterfaceObjects() {
        self.backButton.onButtonTapped = {[weak self] _ in
            guard let this = self else {return}
            this.dismissDelegate?.onDismissTapped(this)
        }
        self.navigationItem.leftBarButtonItem = backButton
        
        self.bottomActionButton.setGrayFormat()
        self.paymentsCollectionView.backgroundColor = .clear
    }

    func setupBindings() {
        // Producers
        self.navigationItem.reactive.title <~ self.viewModel.title
        self.viewModel.navigationRightButton.producer.startWithValues{
            [weak self] in
            self?.navigationItem.rightBarButtonItem = $0
        }
        self.bottomActionButton.reactive.title <~ self.viewModel.bottomActionButtonTitle
        self.bottomActionButton.reactive.isHidden <~ self.viewModel.bottomActionButtonHidden
        self.viewModel.error.producer.skipNil().startWithValues{
            GZEAlertService.shared.showBottomAlert(text: $0)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 5000)) {
            self.paymentsCollectionView.reactive.cells <~ self.viewModel.paymentslist
        }

        // Signals
        self.viewModel.loading.signal.skipRepeats().observeValues{loading in
            if loading {
                SwiftOverlays.showBlockingWaitOverlay()
            } else {
                SwiftOverlays.removeAllBlockingOverlays()
            }
        }
        self.viewModel.segueAvailableMethods.signal.observeValues{[weak self] vm in
            guard let this = self else {return}
            guard let controller = this.storyboard?.instantiateViewController(withIdentifier: "GZEPaymentMethodsViewController") as? GZEPaymentMethodsViewController else {
                log.error("Unable to instantiate GZEPaymentMethodsViewController")
                return
            }
            guard let navController = this.navigationController else {
                log.error("Unable to get navigationController")
                return
            }

            controller.viewModel = vm
            controller.dismissDelegate = self
            navController.pushViewController(controller, animated: true)
        }
        self.viewModel.addPayPal.signal.observeValues {[weak self] in
            guard let this = self else {return}
            this.viewModel.loading.value = true
            PayPalService.shared.savePaymentMethod(presenter: this) {[weak self] success in
                guard let this = self else {return}
                this.viewModel.loading.value = false
                if success {
                    this.dismissDelegate?.onDismissTapped(this)
                }
            }
        }
        self.viewModel.dismiss.signal.observeValues{[weak self] in
            guard let this = self else {return}
            this.dismissDelegate?.onDismissTapped(this)
        }

        // Actions
        self.bottomActionButton.reactive.pressed = self.viewModel.bottomActionButtonAction
    }
    // MARK: - DismissDelegate
    func onDismissTapped(_ vc: UIViewController) {
        if vc.isKind(of: GZEPaymentMethodsViewController.self) {
            vc.previousController(animated: true)
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

    deinit {
        log.debug("\(self) disposed")
    }
}
