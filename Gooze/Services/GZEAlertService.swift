//
//  GZEAlertService.swift
//  Gooze
//
//  Created by Yussel on 3/25/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import SwiftOverlays
import LGAlertView

class GZEAlertService {
    static var shared = GZEAlertService()

    private var window: UIWindow? {
        return UIApplication.shared.keyWindow
    }
    
    private let bottomAlert = GZEValidationErrorView()
    private let topAlert = GZEValidationErrorView()
    private let actionAlert = GZEActionAlertView()
    
    private var bottomConstraint: NSLayoutConstraint!
    
    private var topTimer: Timer?
    private var botTimer: Timer?
    
    init() {
        guard let superview = self.window else {
            log.error("key window not found. Alerts will not be shown")
            return
        }
        
        self.topAlert.onDismiss = {[weak self] in
            log.debug("topAlert onDimiss called")
            self?.topTimer?.invalidate()
            self?.topTimer = nil
            self?.topAlert.onTapped = nil
        }
        
        self.bottomAlert.onDismiss = {[weak self] in
            log.debug("bottomAlert onDimiss called")
            self?.botTimer?.invalidate()
            self?.botTimer = nil
            self?.bottomAlert.onTapped = nil
        }
        
        superview.addSubview(self.topAlert)
        self.topAlert.heightAnchor.constraint(equalToConstant: 60).isActive = true
        superview.widthAnchor.constraint(equalTo: self.topAlert.widthAnchor).isActive = true
        superview.topAnchor.constraint(equalTo: self.topAlert.topAnchor, constant: -statusBarHeight()).isActive = true
        superview.centerXAnchor.constraint(equalTo: self.topAlert.centerXAnchor).isActive = true
        
        superview.addSubview(self.bottomAlert)
        self.bottomAlert.heightAnchor.constraint(equalToConstant: 60).isActive = true
        superview.widthAnchor.constraint(equalTo: self.bottomAlert.widthAnchor).isActive = true
        self.bottomConstraint = superview.bottomAnchor.constraint(equalTo: self.bottomAlert.bottomAnchor)
        if #available(iOS 11.0, *) {
            self.bottomConstraint.constant = superview.safeAreaInsets.bottom
        }
        self.bottomConstraint.isActive = true
        superview.centerXAnchor.constraint(equalTo: self.bottomAlert.centerXAnchor).isActive = true
        
        registerForKeyboarNotifications(
            observer: self,
            willShowSelector: #selector(keyboardWillShow(notification:)),
            willHideSelector: #selector(keyboardWillHide(notification:))
        )
    }

    func showTopAlert(text: String, duration: TimeInterval = 5, animated: Bool = true, onTapped: (() -> ())? = nil) {
        log.debug("showing top alert")
        if self.topTimer != nil {
            self.topTimer?.invalidate()
            self.topTimer = nil
        }
        self.topTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.dismissTopAlert), userInfo: nil, repeats: false)

        self.topAlert.onTapped = onTapped
        self.topAlert.text = text
        self.topAlert.show()
    }
    
    func showBottomAlert(text: String, duration: TimeInterval = 5, animated: Bool = true, onTapped: (() -> ())? = nil) {
        log.debug("showing bottom alert")
        if self.botTimer != nil {
            self.botTimer?.invalidate()
            self.botTimer = nil
        }
        self.botTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.dismissBottomAlert), userInfo: nil, repeats: false)
        
        self.bottomAlert.onTapped = onTapped
        self.bottomAlert.text = text
        self.bottomAlert.show()
    }

    @objc func dismissTopAlert() {
        log.debug("dismissing top alert")
        self.topAlert.dismiss()
    }
    
    @objc func dismissBottomAlert() {
        log.debug("dismissing bot alert")
        self.bottomAlert.dismiss()
    }

    func showConfirmDialog(
        title: String? = nil,
        message: String? = nil,
        buttonTitles: [String] = [],
        cancelButtonTitle: String? = nil,
        destructiveButtonTitle: String? = nil,
        actionHandler: LGAlertViewActionHandler? = nil,
        cancelHandler: LGAlertViewHandler? = nil,
        destructiveHandler: LGAlertViewHandler? = nil
    ) {
        let alertView = LGAlertView(
            title: title,
            message: message,
            style: .alert,
            buttonTitles: buttonTitles,
            cancelButtonTitle: cancelButtonTitle,
            destructiveButtonTitle: destructiveButtonTitle,
            actionHandler: actionHandler,
            cancelHandler: cancelHandler,
            destructiveHandler: destructiveHandler
        )

        alertView.backgroundColor = UIColor(white: 0.7, alpha: 1)

        alertView.tintColor = .black
        alertView.titleFont = GZEConstants.Font.main.increase(by: 2)
        alertView.messageFont = GZEConstants.Font.main
        alertView.buttonsFont = GZEConstants.Font.main.increase(by: 2)
        alertView.cancelButtonFont = GZEConstants.Font.main.increase(by: 2)
        alertView.destructiveButtonFont = GZEConstants.Font.main.increase(by: 2)

        alertView.showAnimated()
    }

    func dismissActionAlert() {
        self.actionAlert.dismiss()
    }

    func clear() {
        self.topTimer?.invalidate()
        self.topTimer = nil
        self.botTimer?.invalidate()
        self.botTimer = nil

        self.topAlert.removeFromSuperview()
        self.bottomAlert.removeFromSuperview()
        self.actionAlert.removeFromSuperview()

        deregisterFromKeyboardNotifications(observer: self)
    }
    
    // MARK: - KeyboardNotifications
    @objc func keyboardWillShow(notification: Notification) {
        log.debug("keyboard will show")
        guard let window = self.window else {
            log.error("key window not found")
            return
        }
        resizeViewWithKeyboard(keyboardShow: true, constraint: self.bottomConstraint, notification: notification, view: window, safeInsets: false)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        log.debug("keyboard will hide")
        guard let window = self.window else {
            log.error("key window not found")
            return
        }
        resizeViewWithKeyboard(keyboardShow: false, constraint: self.bottomConstraint, notification: notification, view: window)
    }
    
}
