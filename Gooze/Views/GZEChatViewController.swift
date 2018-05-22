//
//  GZEChatViewController.swift
//  Gooze
//
//  Created by Yussel on 3/30/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZEChatViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    let segueToPayment = "segueToPayment"
    let segueToMap = "segueToMap"

    var viewModel: GZEChatViewModel!
    var scrollTableOnShow = false
    let backButton = GZEBackUIBarButtonItem()
    var collectionViewTopScrollDisposable: Disposable?

    @IBOutlet weak var topActionView: GZEChatActionView!
    @IBOutlet weak var topTextInput: UITextField! {
        didSet {
            self.topTextInput.layer.borderWidth = 1
            self.topTextInput.layer.borderColor = GZEConstants.Color.mainGreen.cgColor
            self.topTextInput.layer.cornerRadius = 5
            self.topTextInput.layer.masksToBounds = true
            
            self.topTextInput.textAlignment = .center
            self.topTextInput.backgroundColor = GZEConstants.Color.buttonBackground
            self.topTextInput.font = GZEConstants.Font.main
            self.topTextInput.textColor = GZEConstants.Color.mainTextColor
            self.topTextInput.tintColor = GZEConstants.Color.mainTextColor
            self.topTextInput.delegate = self
        }
    }
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var messagesTableView: GZEMessagesTableView!
    @IBOutlet weak var messageTextView: UITextView! {
        didSet {
            self.messageTextView.delegate = self
            self.messageTextView.layer.cornerRadius = 10
            self.messageTextView.layer.masksToBounds = true
            self.messageTextView.tintColor = .black
        }
    }
    @IBOutlet weak var messageInputContainer: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageInputContainerBottomSpacing: NSLayoutConstraint!
    @IBOutlet weak var messageInputHeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        log.debug("\(self) init")
        super.viewDidLoad()
        
        backButton.onButtonTapped = {[weak self] _ in
            self?.previousController(animated: true)
        }
        self.navigationItem.setLeftBarButton(backButton, animated: false)
        self.navigationItem.reactive.title <~ self.viewModel.username.map{$0?.uppercased()}

        setupBindings()
    }
    
    // TODO: scroll bottom on orientation change
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.messagesTableView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GZEChatService.shared.activeChatId = self.viewModel.chat.id
        
        self.viewModel.startObservers()
        self.observeCollectionViewTopScroll()
  
        registerForKeyboarNotifications(
            observer: self,
            willShowSelector: #selector(keyboardWillShow(notification:)),
            willHideSelector: #selector(keyboardWillHide(notification:)),
            didShowSelector: #selector(keyboardDidShow(notification:))
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.collectionViewTopScrollDisposable?.dispose()
        self.viewModel.stopObservers()
        GZEChatService.shared.activeChatId = nil
        deregisterFromKeyboardNotifications(observer: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupBindings() {
        self.topActionView.mainButton.reactive.title <~ self.viewModel.topButtonTitle
        self.topActionView.reactive.isHidden <~ self.viewModel.topButtonIsHidden
        self.topActionView.mainButton.reactive.pressed = self.viewModel.topButtonAction
        
        self.topActionView.accessoryButton.reactive.isHidden <~ self.viewModel.topAccessoryButtonIsHidden
        self.topActionView.accessoryButton.reactive.pressed = self.viewModel.topAccessoryButtonAction
        
        self.viewModel.topTextInput <~ self.topTextInput.reactive.continuousTextValues
        self.topTextInput.reactive.text <~ self.viewModel.topTextInput
        
        self.viewModel.topTextInputIsHidden.producer.startWithValues {[weak self] isHidden in
            self?.topTextInput.isHidden = isHidden
            if !isHidden {
                self?.topTextInput.becomeFirstResponder()
            }
        }

        self.viewModel.inputMessage <~ self.messageTextView.reactive.continuousTextValues
        
        self.viewModel.inputMessage.signal.observeValues {[weak self] text in
            guard let this = self else {return}
            this.messageTextView.text = text
        }

        self.viewModel.messages.producer.startWithValues {[weak self] in
            self?.messagesTableView.messagesObserver.send(value: $0)
        }

        self.sendButton.reactive.pressed = self.viewModel.sendButtonAction
        
        self.viewModel.showPaymentViewSignal.observeValues {[weak self] _ in
            guard let this = self else {return}
            this.performSegue(withIdentifier: this.segueToPayment, sender: nil)
        }

        self.viewModel.showMapViewSignal.observeValues {[weak self] _ in
            guard let this = self else {return}
            this.performSegue(withIdentifier: this.segueToMap, sender: nil)
        }
    }

    func observeCollectionViewTopScroll() {
        collectionViewTopScrollDisposable = self.messagesTableView
            .topScrollSignal
            .debounce(0.5, on: QueueScheduler.main)
            .flatMap(.latest, transform: {[weak self] _ -> SignalProducer<Void, GZEError> in
                guard let this = self else {
                    log.error("self was disposed")
                    return SignalProducer.empty
                }
                guard let retrieveHistoryProducer = this.viewModel.retrieveHistoryProducer else {
                    log.error("found nil retrieveHistoryProducer")
                    return SignalProducer.empty
                }
                return (
                    retrieveHistoryProducer
                        .flatMapError{ error in
                            log.error(error.localizedDescription)
                            return SignalProducer.empty
                    }
                )
            })
            .observe { event in
                log.debug("event: \(event)")
        }
    }
    
    // MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView)
    {
        self.view.layoutIfNeeded()
        if textView.contentSize.height >= self.messageInputHeightConstraint.constant
        {
            textView.isScrollEnabled = true
        }
        else
        {
            textView.isScrollEnabled = false
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        log.debug("textFieldShouldReturn")
        
        // textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        log.debug("textFieldDidEndEditing")
        self.viewModel.topTextInputIsHidden.value = true
    }
    

    // MARK: - KeyboardNotifications
    func keyboardWillShow(notification: Notification) {
        log.debug("keyboard will show")
        if self.messagesTableView.isAtBottom {
            self.scrollTableOnShow = true
        }
        resizeViewWithKeyboard(keyboardShow: true, constraint: self.messageInputContainerBottomSpacing, notification: notification, view: self.view)
    }
    
    func keyboardDidShow(notification: Notification) {
        if self.scrollTableOnShow {
            self.scrollTableOnShow = false
            self.messagesTableView.scrollToBottom(animated: false)
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        log.debug("keyboard will hide")
        resizeViewWithKeyboard(keyboardShow: false, constraint: self.messageInputContainerBottomSpacing, notification: notification, view: self.view)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == segueToPayment {

            showPaymentView(segue.destination)

        } else if segue.identifier == segueToMap {

            showDatesMapView(segue.destination)

        }
    }
    
    func showPaymentView(_ vc: UIViewController) {
        log.debug("Trying to show payment view...")
        if let view = vc as? GZEPaymentViewController {
            
            log.debug("payment view instantiated. Setting up its view model")
            guard let vm = self.viewModel.paymentViewModel else {
                log.error("Unable to instantiate payment view model")
                GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
                return
            }

            view.viewModel = vm

        } else {
            log.error("Unable to instantiate GZEPaymentViewController")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
        }
    }

    func showDatesMapView(_ vc: UIViewController) {
        log.debug("Trying to show dates map view...")
        if let view = vc as? GZEMapViewController {

            log.debug("dates map view instantiated. Setting up its view model")

            guard let vm = self.viewModel.mapViewModel else {
                log.error("Unable to instantiate map view model")
                GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
                return
            }

            view.viewModel = vm

        } else {
            log.error("Unable to instantiate GZEMapViewController")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
        }
    }

    // MARK: - Deinitializer
    deinit {
        log.debug("\(self) disposed")
    }

}
