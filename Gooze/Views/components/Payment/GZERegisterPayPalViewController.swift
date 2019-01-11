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
    let nextButton = GZENextUIBarButtonItem()

    let loadingView = GZELoadingUIView()

    let emailTextField = GZETextField()
    let emailConfirmTextField = GZETextField()

    @IBOutlet weak var botRightButton: GZEButton!
    @IBOutlet weak var botLeftButton: GZEButton!
    @IBOutlet weak var dblCtrlView: GZEDoubleCtrlView!

    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("\(self) init")

        setupInterfaceObjects()
        setupBindings()

        if let text = self.viewModel.descriptionLabelText.value {
            GZEAlertService.shared.showTopAlert(text: text, duration: 10)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.viewShownObs.send(value: true)
        registerForKeyboarNotifications(
            observer: self,
            willShowSelector: #selector(keyboardWillShow(notification:)),
            willHideSelector: #selector(keyboardWillHide(notification:))
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deregisterFromKeyboardNotifications(observer: self)
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


        self.nextButton.onButtonTapped = {[weak self] _ in
            self?.botRightButton.sendActions(for: .touchUpInside)
        }

        self.viewModel.rightBarButtonItem.value = nextButton

        self.loadingView.containerView = self.view

        emailTextField.autocapitalizationType = .none
        emailTextField.keyboardType = .emailAddress
        emailTextField.tintColor = .white
        emailTextField.font = GZEConstants.Font.main
        emailTextField.attributedPlaceholder = NSAttributedString(string: self.viewModel.emailPlaceholder.value.uppercased(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: GZEConstants.Font.main])

        emailConfirmTextField.autocapitalizationType = .none
        emailConfirmTextField.keyboardType = .emailAddress
        emailConfirmTextField.tintColor = .white
        emailConfirmTextField.font = GZEConstants.Font.main
        emailConfirmTextField.attributedPlaceholder = NSAttributedString(string: self.viewModel.emailConfirmPlaceholder.value.uppercased(), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: GZEConstants.Font.main])

        self.dblCtrlView.minSeparatorWidth = 200
        self.dblCtrlView.topCtrlView = emailTextField
        self.dblCtrlView.bottomCtrlView = emailConfirmTextField

        self.dblCtrlView.topViewTappedHandler = {[weak self] _ in
            self?.emailTextField.becomeFirstResponder()
        }

        self.dblCtrlView.bottomViewTappedHandler = {[weak self] _ in
            self?.emailConfirmTextField.becomeFirstResponder()
        }
    }

    func setupBindings() {
        // Producers
        self.navigationItem.reactive.title <~ self.viewModel.title

        self.viewModel.rightBarButtonItem
            .combineLatest(with: self.viewModel.showRightBarButton)
            .producer
            .startWithValues{[weak self] (button, show) in
                self?.navigationItem.rightBarButtonItem = show ? button : nil
            }

        self.emailTextField.reactive.text <~ self.viewModel.emailText
        self.emailConfirmTextField.reactive.text <~ self.viewModel.emailConfirmText

        self.viewModel.emailText <~ self.emailTextField.reactive.continuousTextValues
        self.viewModel.emailConfirmText <~ self.emailConfirmTextField.reactive.continuousTextValues

        self.botRightButton.reactive.title <~ self.viewModel.botRightButtonTitle
        self.botRightButton.reactive.isHidden <~ self.viewModel.botRightButtonHidden

        self.botLeftButton.reactive.title <~ self.viewModel.botLeftButtonTitle
        self.botLeftButton.reactive.isHidden <~ self.viewModel.botLeftButtonHidden

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
        self.botLeftButton.reactive.pressed = self.viewModel.botLeftButtonAction
    }

    // MARK: - KeyboardNotifications

    @objc func keyboardWillShow(notification: Notification) {
        log.debug("keyboard will show")
        resizeViewWithKeyboard(keyboardShow: true, constraint: bottomLayoutConstraint, notification: notification, view: self.view)
    }

    @objc func keyboardWillHide(notification: Notification) {
        log.debug("keyboard will hide")
        resizeViewWithKeyboard(keyboardShow: false, constraint: bottomLayoutConstraint, notification: notification, view: self.view, safeInsets: false)
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    static func prepareView(presenter: GZEDismissVCDelegate, nextDelegate: GZENextVCDelegate? = nil, viewController: UIViewController, vm: Any?, showRightBarButton: Bool = false) {

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

        vm.showRightBarButton.value = showRightBarButton

        viewController.dismissDelegate = presenter
        viewController.nextDelegate = nextDelegate
        viewController.viewModel = vm
    }

    deinit {
        log.debug("\(self) disposed")
    }

}
