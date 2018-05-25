//
//  UIView+Extensions.swift
//  Gooze
//
//  Created by Yussel on 12/26/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import SwiftOverlays


extension UIView {
    enum Position {
        case top
        case bottom
    }

    @discardableResult
    func addBorder(at: Position, color: UIColor, width: CGFloat) -> CALayer {
        let border = CALayer()
        let size = self.bounds
        var rect: CGRect

        switch at {
        case .top:
            rect = CGRect(
                x: 0,
                y: 0,
                width: size.width,
                height: width
            )
        case .bottom:
            rect = CGRect(
                x: 0,
                y: size.height - width,
                width: size.width,
                height: width
            )
        }

        border.backgroundColor = color.cgColor
        border.frame = rect

        self.layer.addSublayer(border)

        return border
    }

    func showWaitIndicator() {
        SwiftOverlays.showCenteredWaitOverlay(self)
    }

    func removeWaitIndicator() {
        SwiftOverlays.removeAllOverlaysFromView(self)
    }
}


extension UIViewAnimationCurve {
    func toOptions() -> UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: UInt(rawValue << 16))
    }
}
