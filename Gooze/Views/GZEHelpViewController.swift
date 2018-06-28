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

    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var bottomButton: GZEButton!

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

        self.bottomButton.setGrayFormat()

        self.subjectTextField.backgroundColor = UIColor.clear
        self.subjectTextField.borderStyle = .none
        self.subjectTextField.textColor = UIColor.white
        self.subjectTextField.textAlignment = .left
        self.subjectTextField.font = GZEConstants.Font.main
        self.subjectTextField.attributedPlaceholder = NSAttributedString(
            string: viewModel.subjectPlaceholder.value,
            attributes: [
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName: GZEConstants.Font.main
            ]
        )
        self.bodyTextView.backgroundColor = .clear
        self.bodyTextView.textColor = UIColor.white
        self.bodyTextView.font = GZEConstants.Font.main
        self.bodyTextView.tintColor = GZEConstants.Color.buttonBackground
        self.bodyTextView.delegate = self
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
}
