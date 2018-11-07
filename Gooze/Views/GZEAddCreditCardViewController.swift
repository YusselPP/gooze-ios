//
//  GZEAddCreditCardViewController.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/26/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class GZEAddCreditCardViewController: UIViewController {

    var viewModel: GZEAddCreditCardViewModel!

    let nameFieldTitle = "view.credit.card.name.title".localized().uppercased()

    @IBOutlet weak var nameField: GZEFloatingLabelTextField!
    @IBOutlet weak var cardNumberField: GZECardNumber!
    @IBOutlet weak var expMonthField: GZEMonthNumber!
    @IBOutlet weak var expYearField: GZEYearNumber!
    @IBOutlet weak var ccvField: GZECVC!

    @IBOutlet weak var actionButton: GZEButton!

    @IBOutlet weak var contentBottomConstrint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel.controller = self

        self.setupInterfaceObjects()
        self.setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupInterfaceObjects() {
        self.actionButton.setGrayFormat()
        self.nameField.placeholder = nameFieldTitle
        self.nameField.selectedTitle = nameFieldTitle
        self.nameField.title = nameFieldTitle
        self.nameField.autocorrectionType = .no
        self.nameField.iconWidth = 0
        self.nameField.autocapitalizationType = .allCharacters
    }

    func setupBindings() {
        // outputs
        self.nameField.reactive.text <~ self.viewModel.name
        self.cardNumberField.reactive.text <~ self.viewModel.cardNumber
        self.expMonthField.reactive.text <~ self.viewModel.expMonth
        self.expYearField.reactive.text <~ self.viewModel.expYear
        self.ccvField.reactive.text <~ self.viewModel.cvc
        self.actionButton.reactive.title <~ self.viewModel.actionButtonTitle

        // inputs
        self.viewModel.name <~ self.nameField.reactive.continuousTextValues
        self.viewModel.cardNumber <~ self.cardNumberField.normalizedText
        self.viewModel.expMonth <~ self.expMonthField.normalizedText
        self.viewModel.expYear <~ self.expYearField.normalizedText
        self.viewModel.cvc <~ self.ccvField.normalizedText

        // actions
        self.actionButton.reactive.pressed = self.viewModel.actionButton

        // signals
        self.viewModel.error.producer.skipNil().startWithValues{
            GZEAlertService.shared.showBottomAlert(text: $0)
        }

        self.viewModel.loading.producer.startWithValues{[weak self] loading in
            guard let this = self else {return}
            if loading {
                this.showLoading()
            } else {
                this.hideLoading()
            }
        }

        self.viewModel.dismiss.signal.observeValues{[weak self] in
            self?.previousController(animated: true)
        }
    }

    // MARK: - KeyboardNotifications

    @objc func keyboardWillShow(notification: Notification) {
        log.debug("keyboard will show")
        resizeViewWithKeyboard(keyboardShow: true, constraint: contentBottomConstrint, notification: notification, view: self.view)
    }

    @objc func keyboardWillHide(notification: Notification) {
        log.debug("keyboard will hide")
        resizeViewWithKeyboard(keyboardShow: false, constraint: contentBottomConstrint, notification: notification, view: self.view, safeInsets: false)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
