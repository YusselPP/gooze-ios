//
//  GZEImageHelper.swift
//  Gooze
//
//  Created by Yussel on 11/8/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

class GZEImageHelper {

    static func compressImage(_ image: UIImage) -> UIImage? {

        var compressedImage: UIImage?
        let maxWidth: CGFloat = 800.0
        let maxHeight: CGFloat = 600.0
        let compression: CGFloat = 0.5
        let maxRatio = maxWidth/maxHeight

        var actualHeight = image.size.height
        var actualWidth = image.size.width
        var imgRatio = actualWidth/actualHeight


        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                // adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if imgRatio > maxRatio {
                // adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }

        let rect = CGRect(x: 0, y: 0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)

        if
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext(),
            let compressedImageData = resizedImage.jpegData(compressionQuality: compression)
        {
            compressedImage = UIImage(data: compressedImageData)
        }
        UIGraphicsEndImageContext()

        return compressedImage
    }
}
