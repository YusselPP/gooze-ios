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
    func setZoomScale(imageView: UIImageView, animated: Bool) {
        let imageViewSize = imageView.bounds.size
        let size = self.bounds.size
        let widthScale = size.width / imageViewSize.width
        let heightScale = size.height / imageViewSize.height
        let minZoomScale = max(widthScale, heightScale)

        self.minimumZoomScale = minZoomScale
        self.setZoomScale(minZoomScale, animated: animated)
    }
}
