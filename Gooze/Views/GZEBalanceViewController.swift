//
//  GZEBalanceViewController.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/28/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import SwiftOverlays

class GZEBalanceViewController: UIViewController, GZEDismissVCDelegate {

    var viewModel: GZEBalanceViewModel!

    weak var dismissDelegate: GZEDismissVCDelegate?

    let backButton = GZEBackUIBarButtonItem()

    let segueToHistoryDetail = "segueToHistoryDetail"

    @IBOutlet weak var collectionView: GZEBalanceCollectionView!
    @IBOutlet weak var rightLabel: GZELabel!
    @IBOutlet weak var bottomStack: UIStackView!
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
        self.collectionView.initDatasource()
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

        self.collectionView.backgroundColor = .clear
        self.collectionView.dataAtBottom = self.viewModel.dataAtBottom

        self.bottomActionButton.setGrayFormat()
    }

    func setupBindings() {
        // Producers
        self.navigationItem.reactive.title <~ self.viewModel.title
        self.collectionView.reactive.cells <~ self.viewModel.list
        self.rightLabel.reactive.text <~ self.viewModel.rightLabelText
        self.rightLabel.reactive.textColor <~ self.viewModel.rightLabelTextColor
        self.bottomStack.reactive.isHidden <~ self.viewModel.bottomStackHidden
        self.bottomActionButton.reactive.title <~ self.viewModel.bottomActionButtonTitle
        self.bottomActionButton.reactive.isHidden <~ self.viewModel.bottomActionButtonHidden
        self.viewModel.error.producer.skipNil().startWithValues{
            GZEAlertService.shared.showBottomAlert(text: $0)
        }

        // Signals
        self.viewModel.loading.signal.skipRepeats().observeValues{[weak self] loading in
            guard let this = self else {return}
            if loading {
                SwiftOverlays.showCenteredWaitOverlay(this.view)
            } else {
                SwiftOverlays.removeAllOverlaysFromView(this.view)
            }
        }

        self.viewModel.segueToHistoryDetail.observeValues{[weak self] vm in
            guard let this = self else {return}
            this.performSegue(withIdentifier: this.segueToHistoryDetail, sender: vm)
        }

        self.viewModel.dismiss.signal.observeValues{[weak self] in
            guard let this = self else {return}
            this.dismissDelegate?.onDismissTapped(this)
        }

        // Actions
        self.bottomActionButton.reactive.pressed = self.viewModel.bottomActionButtonCocoaAction
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
        if segue.identifier == segueToHistoryDetail {

            GZEHistoryDetailViewController.prepareView(
                presenter: self,
                viewController: segue.destination,
                vm: sender
            )
        }
     }


    deinit {
        log.debug("\(self) disposed")
    }

    static func prepareView(presenter: GZEDismissVCDelegate, viewController: UIViewController, vm: Any?) {
        log.debug("Trying to show balance view...")

        guard let viewController = viewController as? GZEBalanceViewController else {
            log.error("Unable to instantiate GZEBalanceViewController")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
            return
        }
        log.debug("view instantiated. Setting up its view model")

        guard let vm = vm as? GZEBalanceViewModel else {
            log.error("Unable to instantiate GZEBalanceViewModel")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
            return
        }

        viewController.dismissDelegate = presenter
        viewController.viewModel = vm
    }
}
