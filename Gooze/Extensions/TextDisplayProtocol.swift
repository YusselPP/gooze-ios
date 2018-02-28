//
//  TextDisplayProtocol.swift
//  Gooze
//
//  Created by Yussel on 11/26/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

protocol TextDisplay {

    func setColor(_ color: UIColor)
    func setTextFont(_ font: UIFont)
    func setAlignment(_ alignment: NSTextAlignment)
    func getText() -> String?
    func setDisplayText(_ text: String?)
    func hasSecureEntry() -> Bool
}

extension UIButton: TextDisplay {

    func setColor(_ color: UIColor) {
        self.setTitleColor(color, for: .normal)
    }

    func setTextFont(_ font: UIFont) {
        self.titleLabel?.font = font
    }

    func setAlignment(_ alignment: NSTextAlignment) {
        self.titleLabel?.textAlignment = alignment
    }

    func getText() -> String? {
        return self.currentTitle
    }

    func setDisplayText(_ text: String?)  {
        self.setTitle(text, for: .normal)
    }

    func hasSecureEntry() -> Bool{
        return false
    }
}

extension UILabel: TextDisplay {

    func setColor(_ color: UIColor) {
        self.textColor = color
    }

    func setTextFont(_ font: UIFont) {
        self.font = font
    }

    func setAlignment(_ alignment: NSTextAlignment) {
        self.textAlignment = alignment
    }

    func getText() -> String? {
        return self.text
    }

    func setDisplayText(_ text: String?)  {
        self.text = text
    }

    func hasSecureEntry() -> Bool{
        return false
    }
}

extension UITextField: TextDisplay {

    func setColor(_ color: UIColor) {
        self.textColor = color
    }

    func setTextFont(_ font: UIFont) {
        self.font = font
    }

    func setAlignment(_ alignment: NSTextAlignment) {
        self.textAlignment = alignment
    }

    func getText() -> String? {
        return self.text
    }

    func setDisplayText(_ text: String?)  {
        self.text = text
    }

    func hasSecureEntry() -> Bool{
        return self.isSecureTextEntry
    }
}
