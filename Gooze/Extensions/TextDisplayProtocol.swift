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
}
