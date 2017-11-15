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
}
