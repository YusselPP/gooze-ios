//
//  GZERegisterPayPalViewController.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 1/5/19.
//  Copyright © 2019 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZERegisterPayPalViewController: UIViewController {

    var viewModel: GZERegisterPayPalViewModel!

    weak var dismissDelegate: GZEDismissVCDelegate?
    weak var nextDelegate: GZENextVCDelegate?

    let backButton = GZEBackUIBarButtonItem()

    let loadingView = GZELoadingUIView()

    @IBOutlet weak var descriptionLabel: GZELabel!
    @IBOutlet weak var emailTextField: GZETextField!
    @IBOutlet weak var emailConfirmTextField: GZETextField!
    @IBOutlet weak var botRightButton: GZEButton!

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

        self.loadingView.containerView = self.view

        emailTextField.keyboardType = .emailAddress
        emailTextField.tintColor = .white
        emailTextField.font = GZEConstants.Font.main
        emailTextField.attributedPlaceholder = NSAttributedString(string: self.viewModel.emailPlaceholder.value, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: GZEConstants.Font.main])

        emailConfirmTextField.keyboardType = .emailAddress
        emailConfirmTextField.tintColor = .white
        emailConfirmTextField.font = GZEConstants.Font.main
        emailConfirmTextField.attributedPlaceholder = NSAttributedString(string: self.viewModel.emailConfirmPlaceholder.value, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: GZEConstants.Font.main])
    }

    func setupBindings() {
        // Producers
        self.navigationItem.reactive.title <~ self.viewModel.title

        self.viewModel.rightBarButtonItem.producer.startWithValues{
            [weak self] in
            self?.navigationItem.rightBarButtonItem = $0
        }

        self.descriptionLabel.reactive.text <~ self.viewModel.descriptionLabelText

        self.emailTextField.reactive.text <~ self.viewModel.emailText
        self.emailConfirmTextField.reactive.text <~ self.viewModel.emailConfirmText

        self.viewModel.emailText <~ self.emailTextField.reactive.continuousTextValues
        self.viewModel.emailConfirmText <~ self.emailConfirmTextField.reactive.continuousTextValues

        self.botRightButton.reactive.title <~ self.viewModel.botRightButtonTitle
        self.botRightButton.reactive.isHidden <~ self.viewModel.botRightButtonHidden
        self.viewModel.error.producer.skipNil().startWithValues{
            GZEAlertService.shared.showBottomAlert(text: $0)
        }

        // Signals
        self.viewModel.loading.signal.observeValues{
            [weak self] loading in
            guard let this = self else {return}
            log.debug("loading: \(loading)")
            if loading > 0 {
                this.loadingView.start()
            } else {
                this.loadingView.stop()
            }
        }

        self.viewModel.dismiss.signal.observeValues{[weak self] in
            guard let this = self else {return}
            this.dismissDelegate?.onDismissTapped(this)
        }

        self.viewModel.next.signal.observeValues{[weak self] in
            guard let this = self else {return}
            this.nextDelegate?.onNextTapped(this)
        }

        // Actions
        self.botRightButton.reactive.pressed = self.viewModel.botRightButtonAction
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    static func prepareView(presenter: GZEDismissVCDelegate, nextDelegate: GZENextVCDelegate? = nil, viewController: UIViewController, vm: Any?, rightBarButton: UIBarButtonItem? = nil) {

        let controllerType = GZERegisterPayPalViewController.self

        log.debug("Trying to show \(controllerType)...")

        guard let viewController = viewController as? GZERegisterPayPalViewController else {
            log.error("Unable to instantiate \(controllerType)")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
            return
        }
        log.debug("view instantiated. Setting up its view model")

        guard let vm = vm as? GZERegisterPayPalViewModel else {
            log.error("Unable to instantiate \(GZERegisterPayPalViewModel.self)")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
            return
        }

        vm.rightBarButtonItem.value = rightBarButton

        viewController.dismissDelegate = presenter
        viewController.nextDelegate = nextDelegate
        viewController.viewModel = vm
    }

    deinit {
        log.debug("\(self) disposed")
    }

}
