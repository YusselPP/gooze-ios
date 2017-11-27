//
//  UIViewController+Extension.swift
//  Gooze
//
//  Created by Yussel on 10/25/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import SwiftOverlays

extension UIViewController {

    func displayMessage(_ title: String, _ message: String) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true)
    }

    func setRootController(controller: UIViewController) -> Void {
        if let window = UIApplication.shared.keyWindow {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = controller
            }, completion: nil)
        }
    }

    func showLoading() {
        SwiftOverlays.showBlockingWaitOverlay()
    }

    func hideLoading() {
        SwiftOverlays.removeAllBlockingOverlays()
    }

    func registerForKeyboarNotifications(observer: Any, didShowSelector: Selector, willHideSelector: Selector) {

        let notifications = NotificationCenter.default
        notifications.addObserver(observer, selector: didShowSelector, name: NSNotification.Name.UIKeyboardDidShow, object: nil)

        notifications.addObserver(observer, selector: willHideSelector, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func addKeyboardInsetAndScroll(scrollView: UIScrollView, activeField: UIView?, notification: Notification) {
        let info = notification.userInfo

        if let kbSize = info?[UIKeyboardFrameEndUserInfoKey] as? CGRect {

            var contentInset = scrollView.contentInset
            contentInset.bottom = kbSize.height
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset

            //let kbOffset = CGPoint(x: 0, y: kbSize.height)

            //UIView.animate(withDuration: 0.25) {
            //    scrollView.contentOffset = kbOffset
            //}

            var aRect : CGRect = self.view.frame
            aRect.size.height -= kbSize.height
            if let activeField = activeField {
                if (!aRect.contains(activeField.frame)) {
                    let scrollTo = CGRect(x: activeField.frame.origin.x, y: activeField.frame.origin.y + 100, width: activeField.frame.width, height: activeField.frame.height+100)

                    scrollView.scrollRectToVisible(scrollTo, animated: false)
                }
            }
        }
    }

    func removeKeyboardInset(scrollView: UIScrollView) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}

