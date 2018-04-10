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

class GZEChatViewController: UIViewController, UITextViewDelegate {

    var viewModel: GZEChatViewModel!
    var onDismissTapped: (() -> ())?
    
    let backButton = GZEBackUIBarButtonItem()

    @IBOutlet weak var topButton: GZEButton! {
        didSet {
            self.topButton.setGrayFormat()
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
    @IBOutlet weak var myVavigationItem: UINavigationItem!
    
    
    override func viewDidLoad() {
        log.debug("\(self) init")
        super.viewDidLoad()
        
        backButton.onButtonTapped = {[weak self] _ in
            self?.onDismissTapped?()
        }
        self.myVavigationItem.setLeftBarButton(backButton, animated: false)
        
        self.myVavigationItem.reactive.title <~ self.viewModel.username

        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GZEChatService.shared.activeRecipientId = self.viewModel.recipientId
        registerForKeyboarNotifications(
            observer: self,
            willShowSelector: #selector(keyboardWillShow(notification:)),
            willHideSelector: #selector(keyboardWillHide(notification:))
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GZEChatService.shared.activeRecipientId = nil
        deregisterFromKeyboardNotifications(observer: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupBindings() {
        self.viewModel.inputMessage <~ self.messageTextView.reactive.continuousTextValues
        
        self.viewModel.inputMessage.signal.observeValues {[weak self] text in
            guard let this = self else {return}
            this.messageTextView.text = text
        }

        self.messagesTableView.messages.bindingTarget <~ self.viewModel.messages

        self.sendButton.reactive.pressed = self.viewModel.sendButtonAction
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
    

    // MARK: - KeyboardNotifications
    func keyboardWillShow(notification: Notification) {
        log.debug("keyboard will show")
        resizeViewWithKeyboard(keyboardShow: true, constraint: self.messageInputContainerBottomSpacing, notification: notification, view: self.view)
    }
    
    func keyboardWillHide(notification: Notification) {
        log.debug("keyboard will hide")
        resizeViewWithKeyboard(keyboardShow: false, constraint: self.messageInputContainerBottomSpacing, notification: notification, view: self.view)
    }

    // MARK: - Deinitializer
    deinit {
        log.debug("\(self) disposed")
    }

}
