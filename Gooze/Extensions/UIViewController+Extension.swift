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

    func displayMessage(_ title: String?, _ message: String) -> Void {
        let alert = UIAlertController(title: title ?? "Gooze", message: message, preferredStyle: .alert)
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

    func logoutButtonTapped(_ sender: Any) {

        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)


        if
            let navController = mainStoryboard.instantiateViewController(withIdentifier: "LoginNavController") as? UINavigationController,
            let loginController = navController.viewControllers.first as? GZELoginViewController {
        // if let loginController = mainStoryboard.instantiateViewController(withIdentifier: "GZELoginViewController") as? GZELoginViewController {

            // Set up initial view model
            loginController.viewModel = GZELoginViewModel(GZEUserApiRepository())
            setRootController(controller: navController)
        } else {
            log.error("Unable to instantiate LoginNavController")
            displayMessage("Unexpected error", "Please contact support")
        }
    }

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

    func addKeyboardInsetAndScroll(scrollView: UIScrollView, activeField: UIView?, notification: Notification) {


        if
            let info = notification.userInfo,
            let kbSize = info[UIKeyboardFrameEndUserInfoKey] as? CGRect
        {
            let duration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.35
            let curve = UIViewAnimationCurve(
                rawValue: info[UIKeyboardAnimationCurveUserInfoKey] as? Int ?? UIViewAnimationCurve.linear.rawValue
            )
            let options = curve?.toOptions() ?? UIViewAnimationOptions.curveLinear

            log.debug(curve as Any)
            log.debug(options)

            var contentInset = scrollView.contentInset
            contentInset.bottom = kbSize.height
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset

            var aRect : CGRect = self.view.frame
            aRect.size.height -= kbSize.height
            if let activeField = activeField {
                if (!aRect.contains(activeField.frame)) {
                    UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                        scrollView.scrollRectToVisible(activeField.frame, animated: false)
                    }, completion: nil)
                }
            }
        }
    }

    func removeKeyboardInset(scrollView: UIScrollView) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    func previousController(animated: Bool) {
        navigationController?.popViewController(animated: animated)
    }
}

