//
//  GZEHelpViewController.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/28/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import SwiftOverlays

class GZEHelpViewController: UIViewController, UITextViewDelegate {

    weak var dismissDelegate: GZEDismissVCDelegate?
    var viewModel: GZEHelpViewModel!

    let backButton = GZEBackUIBarButtonItem()

    let subjectTextField = UITextField()
    let bodyTextView = UITextView()

    @IBOutlet weak var dblCtrlView: GZEDoubleCtrlView!
    @IBOutlet weak var bottomButton: GZEButton!

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var viewBottomLayoutConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("\(self) init")

        setupInterfaceObjects()
        setupBindings()

        GZEAlertService.shared.showTopAlert(text: "vm.help.onLoadMessage".localized())
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

    override func viewDidLayoutSubviews() {
        // let height = UIScreen.main.bounds.height
        let height = containerView.bounds.height
        self.dblCtrlView.bottomHeightConstraint?.constant = height / 8 * 5
        self.dblCtrlView.centerYConstraint?.constant = height / 8
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

        self.bottomButton.setGrayFormat()

        self.subjectTextField.backgroundColor = UIColor.clear
        self.subjectTextField.borderStyle = .none
        self.subjectTextField.attributedPlaceholder = NSAttributedString(
            string: viewModel.subjectPlaceholder.value,
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: GZEConstants.Font.main
            ]
        )
        self.bodyTextView.backgroundColor = .clear
        self.bodyTextView.tintColor = GZEConstants.Color.buttonBackground
        self.bodyTextView.delegate = self

        self.dblCtrlView.topCtrlView = self.subjectTextField
        self.dblCtrlView.bottomCtrlView = self.bodyTextView
        self.dblCtrlView.topViewTappedHandler = {
            [weak self] _ in
            self?.subjectTextField.becomeFirstResponder()
        }
        self.dblCtrlView.bottomViewTappedHandler = {
            [weak self] _ in
            self?.bodyTextView.becomeFirstResponder()
        }
        self.dblCtrlView.separatorWidth = 120
    }

    func setupBindings() {
        // Producers
        self.navigationItem.reactive.title <~ self.viewModel.title
        self.bottomButton.reactive.title <~ self.viewModel.bottomButtonTitle
        self.subjectTextField.reactive.text <~ self.viewModel.subjectText
        self.bodyTextView.reactive.text <~ self.viewModel.bodyText

        self.bodyTextView.text = self.viewModel.bodyPlaceholder.value

        self.viewModel.subjectText <~ self.subjectTextField.reactive.continuousTextValues
        self.viewModel.bodyText <~ self.bodyTextView.reactive.continuousTextValues

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

        self.viewModel.dismiss.signal.observeValues{[weak self] in
            guard let this = self else {return}
            this.dismissDelegate?.onDismissTapped(this)
        }

        // Actions
        self.bottomButton.reactive.pressed = self.viewModel.bottomButtonAction
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let text = viewModel.bodyText.value else {
            textView.text = nil
            return
        }

        if text.isEmpty {
            textView.text = nil
            return
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = viewModel.bodyText.value else {
            textView.text = viewModel.bodyPlaceholder.value
            return
        }

        if text.isEmpty {
            textView.text = viewModel.bodyPlaceholder.value
            return
        }
    }

    deinit {
        log.debug("\(self) disposed")
    }

    static func prepareHelpView(presenter: GZEDismissVCDelegate, viewController: UIViewController, vm: Any?) {
        log.debug("Trying to show help view...")

        guard let viewController = viewController as? GZEHelpViewController else {
            log.error("Unable to instantiate GZEHelpViewController")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
            return
        }
        log.debug("view instantiated. Setting up its view model")

        guard let vm = vm as? GZEHelpViewModelGooze else {
            log.error("Unable to instantiate GZEHelpViewModelGooze")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
            return
        }

        viewController.dismissDelegate = presenter
        viewController.viewModel = vm
    }

    // MARK: - KeyboardNotifications
    @objc func keyboardWillShow(notification: Notification) {
        log.debug("keyboard will show")
        resizeViewWithKeyboard(keyboardShow: true, constraint: viewBottomLayoutConstraint, notification: notification, view: self.view)
    }

    @objc func keyboardWillHide(notification: Notification) {
        log.debug("keyboard will hide")
        resizeViewWithKeyboard(keyboardShow: false, constraint: viewBottomLayoutConstraint, notification: notification, view: self.view, safeInsets: false)
    }

}
