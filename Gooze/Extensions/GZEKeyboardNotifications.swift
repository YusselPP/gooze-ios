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

func resizeViewWithKeyboard(keyboardShow: Bool, constraint: NSLayoutConstraint, notification: Notification, view: UIView) {
    if
        keyboardShow,
        let info = notification.userInfo,
        let kbSize = info[UIKeyboardFrameEndUserInfoKey] as? CGRect
    {
        let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.35
        let curve = UIViewAnimationCurve(
            rawValue: info[UIKeyboardAnimationCurveUserInfoKey] as? Int ?? UIViewAnimationCurve.linear.rawValue
        )
        let options = curve?.toOptions() ?? UIViewAnimationOptions.curveLinear
        
        constraint.constant = kbSize.height
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            view.layoutIfNeeded()
        }, completion: nil)
    } else {
        constraint.constant = 0
    }
}
