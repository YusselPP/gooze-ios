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
        notifications.addObserver(observer, selector: showSelector, name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    notifications.addObserver(observer, selector: willHideSelector, name: UIResponder.keyboardWillHideNotification, object: nil)
    notifications.addObserver(observer, selector: willShowSelector, name: UIResponder.keyboardWillShowNotification, object: nil)
}

func deregisterFromKeyboardNotifications(observer: Any) {

    let notifications = NotificationCenter.default
    notifications.removeObserver(observer, name: UIResponder.keyboardDidShowNotification, object: nil)
    notifications.removeObserver(observer, name: UIResponder.keyboardWillHideNotification, object: nil)
    notifications.removeObserver(observer, name: UIResponder.keyboardWillShowNotification, object: nil)
}

func resizeViewWithKeyboard(keyboardShow: Bool, constraint: NSLayoutConstraint, notification: Notification, view: UIView, safeInsets: Bool = true) {

    log.debug("keyboardShow: \(keyboardShow)")
    log.debug("userInfo: \(String(describing: notification.userInfo))")

    var options: UIView.AnimationOptions = .curveLinear
    var duration: TimeInterval = 0.35
    var kbSize: CGRect? = nil

    if let info = notification.userInfo {
        duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? duration
        let curve = UIView.AnimationCurve(
            rawValue: info[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? UIView.AnimationCurve.linear.rawValue
        )
        options = curve?.toOptions() ?? options
        kbSize = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
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
