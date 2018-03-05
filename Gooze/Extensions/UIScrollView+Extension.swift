//
//  UIScrollView+Extension.swift
//  Gooze
//
//  Created by Yussel on 2/3/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

extension UIScrollView {

    func centerContent(animated: Bool) {
        let centerX = self.contentSize.width / 2 - self.bounds.size.width / 2
        let centerY = self.contentSize.height / 2 - self.bounds.size.height / 2

        self.setContentOffset(CGPoint(x: centerX, y: centerY), animated: animated)
    }

    //fit imageview in the scrollview
    func setZoomScale(aRect: CGRect, fitIn rect: CGRect, animated: Bool) {
        let widthScale = rect.width / aRect.width
        let heightScale = rect.height / aRect.height

        self.minimumZoomScale = min(widthScale, heightScale)
        self.setZoomScale(max(widthScale, heightScale), animated: animated)
    }
}
