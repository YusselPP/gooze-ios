//
//  GZEButton.swift
//  Gooze
//
//  Created by Yussel on 3/5/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEButton: UIButton {

    var adjustsWidthToTitle: Bool = true {
        didSet {
            if adjustsWidthToTitle {
                setWidthTofitTitle()
            }
        }
    }
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
        translatesAutoresizingMaskIntoConstraints = false
        widthConstraint = widthAnchor.constraint(equalToConstant: 100)
        heightConstraint = heightAnchor.constraint(equalToConstant: 35)
        widthConstraint.isActive = true
        heightConstraint.isActive = true

        titleEdgeInsets.left = 10
        titleEdgeInsets.right = 10
    }

    func setGrayFormat() {
        layer.borderWidth = 1
        layer.borderColor = GZEConstants.Color.mainGreen.cgColor
        layer.cornerRadius = 5
        layer.masksToBounds = true

        setTextFont(GZEConstants.Font.main)
        tintColor = UIColor.white
    }

    override func setTitle(_ title: String?, for state: UIControlState) {
        super.setTitle(title, for: state)
        if adjustsWidthToTitle {
            setWidthTofitTitle()
        }
    }

    func setWidthTofitTitle() {
        if let title = currentTitle as NSString? {
            let titleSize = title.size(attributes: [NSFontAttributeName: titleLabel!.font!])
            let width = titleSize.width + titleEdgeInsets.left + titleEdgeInsets.right
            widthConstraint.constant = width
        }
    }
}
