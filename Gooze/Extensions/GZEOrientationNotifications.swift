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
        notifications.addObserver(observer, selector: didChangeselector, name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    if let willChangeSelector = willChangeSelector {
        notifications.addObserver(observer, selector: willChangeSelector, name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)
    }
}

func deregisterFromOrientationNotifications(observer: Any) {

    let notifications = NotificationCenter.default
    notifications.removeObserver(observer, name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    notifications.removeObserver(observer, name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation, object: nil)
}
