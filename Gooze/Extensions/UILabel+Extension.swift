//
//  UILabel+Extension.swift
//  Gooze
//
//  Created by Yussel on 12/25/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

extension UILabel {

    func setText(_ text: String?, animated: Bool) {
        if animated {
            UIView.transition(with: self, duration: 0.5, options: [.transitionCrossDissolve, .allowAnimatedContent], animations: { [weak self] in
                self?.text = text
            })
        } else {
            self.text = text
        }
    }

    func setColor(_ color: UIColor?, animated: Bool) {
        if animated {
            UIView.transition(with: self, duration: 1, options: [.transitionCrossDissolve, .allowAnimatedContent], animations: { [weak self] in
                self?.textColor = color
            })
        } else {
            self.textColor = color
        }
    }
}
