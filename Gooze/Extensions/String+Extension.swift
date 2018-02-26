//
//  String+Extension.swift
//  Gooze
//
//  Created by Yussel on 1/24/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

extension String {
    func addQuotes() -> String {
        return "\"" + self + "\""
    }

    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }

    func size(font: UIFont) -> CGSize {
        let nsString = self as NSString
        return nsString.size(attributes: [NSFontAttributeName: font])
    }
}
