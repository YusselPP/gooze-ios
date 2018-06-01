//
//  UIFont+Extension.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/27/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

extension UIFont {

    func increase(by points: CGFloat) -> UIFont {
        return self.withSize(self.pointSize + points)
    }
}
