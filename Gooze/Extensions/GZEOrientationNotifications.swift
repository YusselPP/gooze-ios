//
//  GZEOrientationNotifications.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/29/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

func statusBarHeight() -> CGFloat {
    let statusBarSize = UIApplication.shared.statusBarFrame.size
    return Swift.min(statusBarSize.width, statusBarSize.height)
}

func registerForOrientationNotifications(observer: Any, didChangeselector: Selector? = nil, willChangeSelector: Selector? = nil) {

    let notifications = NotificationCenter.default
    if let didChangeselector = didChangeselector {
        notifications.addObserver(observer, selector: didChangeselector, name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    if let willChangeSelector = willChangeSelector {
        notifications.addObserver(observer, selector: willChangeSelector, name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
    }
}

func deregisterFromOrientationNotifications(observer: Any) {

    let notifications = NotificationCenter.default
    notifications.removeObserver(observer, name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    notifications.removeObserver(observer, name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
}
