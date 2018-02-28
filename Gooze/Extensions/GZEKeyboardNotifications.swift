//
//  GZEKeyboardNotifications.swift
//  Gooze
//
//  Created by Yussel on 2/26/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

func registerForKeyboarNotifications(observer: Any, willShowSelector: Selector, willHideSelector: Selector) {

    let notifications = NotificationCenter.default
    // notifications.addObserver(observer, selector: didShowSelector, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    notifications.addObserver(observer, selector: willHideSelector, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    notifications.addObserver(observer, selector: willShowSelector, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
}

func deregisterFromKeyboardNotifications(observer: Any) {

    let notifications = NotificationCenter.default
    // notifications.removeObserver(observer, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    notifications.removeObserver(observer, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    notifications.removeObserver(observer, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
}
