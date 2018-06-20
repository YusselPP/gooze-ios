//
//  GZEKeyboardNotifications.swift
//  Gooze
//
//  Created by Yussel on 2/26/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

func registerForKeyboarNotifications(observer: Any, willShowSelector: Selector, willHideSelector: Selector, didShowSelector: Selector? = nil) {

    let notifications = NotificationCenter.default
    if let showSelector = didShowSelector {
        notifications.addObserver(observer, selector: showSelector, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    notifications.addObserver(observer, selector: willHideSelector, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    notifications.addObserver(observer, selector: willShowSelector, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
}

func deregisterFromKeyboardNotifications(observer: Any) {

    let notifications = NotificationCenter.default
    notifications.removeObserver(observer, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    notifications.removeObserver(observer, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    notifications.removeObserver(observer, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
}

func resizeViewWithKeyboard(keyboardShow: Bool, constraint: NSLayoutConstraint, notification: Notification, view: UIView, safeInsets: Bool = true) {

    log.debug("keyboardShow: \(keyboardShow)")
    log.debug("userInfo: \(String(describing: notification.userInfo))")

    var options: UIViewAnimationOptions = .curveLinear
    var duration: TimeInterval = 0.35
    var kbSize: CGRect? = nil

    if let info = notification.userInfo {
        duration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? duration
        let curve = UIViewAnimationCurve(
            rawValue: info[UIKeyboardAnimationCurveUserInfoKey] as? Int ?? UIViewAnimationCurve.linear.rawValue
        )
        options = curve?.toOptions() ?? options
        kbSize = info[UIKeyboardFrameEndUserInfoKey] as? CGRect
    }


    if
        keyboardShow,
        let kbSize = kbSize
    {
        if #available(iOS 11.0, *), safeInsets {
            constraint.constant = kbSize.height - view.safeAreaInsets.bottom
        } else {
            constraint.constant = kbSize.height
        }
    } else {
        if #available(iOS 11.0, *), safeInsets {
            constraint.constant = view.safeAreaInsets.bottom
        } else {
            constraint.constant = 0
        }
    }

    UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
        view.layoutIfNeeded()
    }, completion: nil)
}
