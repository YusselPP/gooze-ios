//
//  GZEHistoryDetailViewController.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 11/10/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZEHistoryDetailViewController: UIViewController, GZEDismissVCDelegate {

    let segueToHelp = "segueToHelp"

    var viewModel: GZEHistoryDetailViewModel!

    weak var dismissDelegate: GZEDismissVCDelegate?

    let backButton = GZEBackUIBarButtonItem()

    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var usernameLabel: GZELabel!
    @IBOutlet weak var status: GZELabel!
    @IBOutlet weak var date: GZELabel!
    @IBOutlet weak var amount: GZELabel!
    @IBOutlet weak var address: GZELabel!

    @IBOutlet weak var bottomActionButton: GZEButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("\(self) init")

        setupInterfaceObjects()
        setUpBindings()
        viewModel.didLoadObs.send(value: ())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.viewModel.startObservers()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //self.viewModel.stopObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - GZEDismissVCDelegate
    func onDismissTapped(_ vc: UIViewController) {
        vc.previousController(animated: true)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == segueToHelp {
            GZEHelpViewController.prepareHelpView(
                presenter: self,
                viewController: segue.destination,
                vm: sender
            )
        }
    }

    private func setupInterfaceObjects() {
        self.backButton.onButtonTapped = {[weak self] _ in
            guard let this = self else {return}
            this.dismissDelegate?.onDismissTapped(this)
        }
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.hidesBackButton = true

        usernameLabel.setWhiteFontFormat(align: .left)
        status.setWhiteFontFormat(align: .right)
        date.setWhiteFontFormat(align: .left)
        amount.setWhiteFontFormat(align: .right)
        address.setWhiteFontFormat(align: .left)
        address.numberOfLines = 0

        bottomActionButton.enableAnimationOnPressed()
        bottomActionButton.setGrayFormat()
    }

    private func setUpBindings() {

        viewModel.error.signal.observeValues { error in
            error.flatMap {
                GZEAlertService.shared.showBottomAlert(text: $0)
            }
        }

        viewModel.loading
            .producer
            .startWithValues {[weak self] loading in
                guard let this = self else {return}
                if loading {
                    this.showLoading()
                } else {
                    this.hideLoading()
                }
        }

        viewModel.segueToHelp.observeValues({[weak self] vm in
            guard let this = self else {return}
            this.performSegue(withIdentifier: this.segueToHelp, sender: vm)
        })

        viewModel.dismissSignal
            .observeValues {[weak self] in
                guard let this = self else {return}
                this.dismissDelegate?.onDismissTapped(this)
        }

        usernameLabel.reactive.text <~ viewModel.username
        status.reactive.text <~ viewModel.status
        date.reactive.text <~ viewModel.date
        amount.reactive.text <~ viewModel.amount
        address.reactive.text <~ viewModel.address

        bottomActionButton.reactive.isHidden <~ viewModel.bottomActionButtonIsHidden
        bottomActionButton.reactive.title <~ viewModel.bottomActionButtonTitle
        bottomActionButton.reactive.pressed = viewModel.bottomActionButtonAction
    }

    // Static methods
    static func prepareView(presenter: GZEDismissVCDelegate, viewController: UIViewController, vm: Any?) {
        log.debug("Trying to show history details view...")

        guard let viewController = viewController as? GZEHistoryDetailViewController else {
            log.error("Received controller is not a GZEHistoryDetailViewController")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
            return
        }
        log.debug("view instantiated. Setting up its view model")

        guard let vm = vm as? GZEHistoryDetailViewModel else {
            log.error("Received vm is not a GZEHistoryDetailViewModel")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
            return
        }

        viewController.dismissDelegate = presenter
        viewController.viewModel = vm
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}

