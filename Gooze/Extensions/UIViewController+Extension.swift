//
//  UIViewController+Extension.swift
//  Gooze
//
//  Created by Yussel on 10/25/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import SwiftOverlays
import ReactiveSwift

extension UIViewController {

    func displayMessage(_ title: String?, _ message: String, onDismiss: (() -> ())? = nil) -> Void {
        let alert = UIAlertController(title: title ?? "Gooze", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { _ in onDismiss?() }))
        present(alert, animated: true)
    }

    func setRootController(controller: UIViewController) -> Void {
        if let window = UIApplication.shared.keyWindow {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                let oldRootVC = window.rootViewController
                window.rootViewController = controller
                oldRootVC?.dismiss(animated: false)
            }, completion: { _ in
                GZEAlertService.shared.clear()
                GZEAlertService.shared = GZEAlertService()
            })
        }
    }

    func showLoading() {
        SwiftOverlays.showBlockingWaitOverlay()
    }

    func hideLoading() {
        SwiftOverlays.removeAllBlockingOverlays()
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

            log.debug("scroll bottom contentInset: \(scrollView.contentInset.bottom)")

            var contentInset = scrollView.contentInset
            contentInset.bottom = kbSize.height
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset

            log.debug("scroll bottom contentInset: \(scrollView.contentInset.bottom)")

            log.debug("Keyboard height \(kbSize.height)")

            log.debug("View frame \(self.view.frame)")

            var aRect : CGRect = self.view.frame
            aRect.size.height -= kbSize.height

            log.debug("View frame \(self.view.frame)")
            log.debug("rect minus kb height \(aRect)")

            if let activeField = activeField {

                log.debug("activeField frame \(activeField.frame)")
                log.debug("View contains active field? \(aRect.contains(activeField.frame))")
                log.debug("scroll contentOffset: \(scrollView.contentOffset)")

                if (!aRect.contains(activeField.frame)) {
                    UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                        //scrollView.contentOffset.y = kbSize.height
                        scrollView.scrollRectToVisible(activeField.frame, animated: false)
                    }, completion: { _ in
                        log.debug("scroll result contentOffset: \(scrollView.contentOffset)")
                    })
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

    func showNavigationBar(_ show: Bool, animated: Bool) {
        navigationController?.setNavigationBarHidden(!show, animated: animated)
    }
}

