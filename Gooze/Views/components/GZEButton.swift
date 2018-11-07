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
    
    var maxWidth: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - 20
    var minWidth: CGFloat = 200

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
        widthConstraint = widthAnchor.constraint(equalToConstant: minWidth)
        heightConstraint = heightAnchor.constraint(equalToConstant: 30)
        widthConstraint.isActive = true
        heightConstraint.isActive = true

        titleEdgeInsets.left = 10
        titleEdgeInsets.right = 10
        
        setTitleColor(.gray, for: .highlighted)
        setTitleColor(.gray, for: .disabled)
    }

    func setGrayFormat() {
        layer.borderWidth = 1
        layer.borderColor = GZEConstants.Color.mainGreen.cgColor
        layer.cornerRadius = 5
        layer.masksToBounds = true

        setTextFont(GZEConstants.Font.main)
        tintColor = GZEConstants.Color.mainTextColor
        backgroundColor = GZEConstants.Color.buttonBackground
    }

    func setGrayFormatToggled() {
        layer.borderWidth = 1
        layer.borderColor = GZEConstants.Color.mainGreen.cgColor
        layer.cornerRadius = 5
        layer.masksToBounds = true

        setTextFont(GZEConstants.Font.main)
        tintColor = GZEConstants.Color.textInputPlacehoderOnEdit
        backgroundColor = GZEConstants.Color.buttonToggledBackground

        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 0.0
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        if adjustsWidthToTitle {
            setWidthTofitTitle()
        }
    }

    func setWidthTofitTitle() {
        if let title = currentTitle as NSString? {
            log.debug("current title: \(title)")
            log.debug("font: \(titleLabel!.font!)")
            let titleSize = title.size(withAttributes: [NSAttributedString.Key.font: titleLabel!.font!])
            var width = titleSize.width + titleEdgeInsets.left + titleEdgeInsets.right + 20
            log.debug("titleSize: \(titleSize)")
            log.debug("width: \(width)")
            width = min(maxWidth, width)
            widthConstraint.constant = max(minWidth, width)
        }
    }
}
