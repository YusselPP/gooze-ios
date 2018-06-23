//
//  GZEEditButton.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/22/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEEditButton: UIButton {

    let minSize = CGSize(width: 50, height: 50)

    var widthConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!

    init() {
        super.init(frame: CGRect.zero)
        initProperties()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initProperties()
    }

    func initProperties() {
        setTitle("\u{f040}", for: .normal)
        setTextFont(GZEConstants.Font.mainAwesome.increase(by: 8))
        setTitleColor(.white, for: .normal)

        setTitleColor(.gray, for: .highlighted)
        setTitleColor(.gray, for: .disabled)

        translatesAutoresizingMaskIntoConstraints = false
        widthConstraint = widthAnchor.constraint(equalToConstant: minSize.width)
        heightConstraint = heightAnchor.constraint(equalToConstant: minSize.height)
        widthConstraint.isActive = true
        heightConstraint.isActive = true
    }
}
