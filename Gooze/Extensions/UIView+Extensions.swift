//
//  UIView+Extensions.swift
//  Gooze
//
//  Created by Yussel on 12/26/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

extension UIViewAnimationCurve {
    func toOptions() -> UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: UInt(rawValue << 16))
    }
}
