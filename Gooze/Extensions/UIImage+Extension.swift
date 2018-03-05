//
//  UIImage+Extension.swift
//  Gooze
//
//  Created by Yussel on 3/4/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

extension UIImage {
    func crop(to cropArea: CGRect) -> UIImage? {
        if let croppedCGImage = self.cgImage?.cropping(to: cropArea) {
            return UIImage(cgImage: croppedCGImage)
        } else {
            return nil
        }
    }
}
