//
//  UITextField+Extension.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/28/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

extension UITextField {

    func rangePosition(_ range: UITextRange) -> Int {
        return self.offset(from: self.beginningOfDocument, to: range.start)
    }

}
