//
//  UIButton+Extension.swift
//  Gooze
//
//  Created by Yussel on 11/27/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

extension UIButton {

    func enableAnimationOnPressed() {
        addTarget(self, action: #selector(handleButtonPressedAnimation(_:)), for: .touchUpInside)
    }

    func handleButtonPressedAnimation(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            sender.alpha = 0
            sender.alpha = 1
        })
    }
}
