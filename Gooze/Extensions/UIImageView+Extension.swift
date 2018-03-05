//
//  UIImage+Extension.swift
//  Gooze
//
//  Created by Yussel on 11/9/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

extension UIImageView {

//    func imageFrame() -> CGRect {
//        let imageView = self
//        let imageViewSize = imageView.frame.size
//        let imgSize = imageView.image?.size
//
//        guard let imageSize = imgSize else {
//            return CGRect.zero
//        }
//
//        let scaleWidth = imageViewSize.width / imageSize.width
//        let scaleHeight = imageViewSize.height / imageSize.height
//        let aspect = fmin(scaleWidth, scaleHeight)
//
//        var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)
//        // Center image
//        imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
//        imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2
//
//        // Add imageView offset
//        imageRect.origin.x += imageView.frame.origin.x
//        imageRect.origin.y += imageView.frame.origin.y
//
//        return imageRect
//    }

    func imageBounds() -> CGRect{
        let imageViewSize = self.bounds.size
        guard let imageSize = self.image?.size else{return CGRect.zero}
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        if imageRatio < imageViewRatio {
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: imageViewSize.height)
        }else{
            let scalFactor = imageViewSize.width / imageSize.width
            let height = imageSize.height * scalFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
        }
    }

    func imageFrame() -> CGRect{
        let imageViewSize = self.frame.size
        guard let imageSize = self.image?.size else{return CGRect.zero}
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        if imageRatio < imageViewRatio {
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: imageViewSize.height)
        }else{
            let scalFactor = imageViewSize.width / imageSize.width
            let height = imageSize.height * scalFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            return CGRect(x: 0, y: topLeftY, width: imageViewSize.width, height: height)
        }
    }

    func imageScale() -> CGFloat {
        let imageView = self
        let imageViewSize = imageView.frame.size
        let imgSize = imageView.image?.size

        guard let imageSize = imgSize else {
            return 1.0
        }

        let scaleWidth = imageViewSize.width / imageSize.width
        let scaleHeight = imageViewSize.height / imageSize.height
        let aspect = fmin(scaleWidth, scaleHeight)

        return aspect
    }
}
