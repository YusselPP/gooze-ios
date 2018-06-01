//
//  GZEFloatingLabelTextField.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/26/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class GZEFloatingLabelTextField: SkyFloatingLabelTextFieldWithIcon {
    var normalStateColor = UIColor(white: 0.7, alpha: 1)
    var selectedStateColor = GZEConstants.Color.mainTextColor

    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        initProperties()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initProperties()
    }

    init() {
        super.init(frame: .zero)
        initProperties()
    }

    private func initProperties() {
        self.iconType = .font
        self.iconFont = GZEConstants.Font.mainAwesome
        self.iconFont = self.iconFont?.increase(by: 8)
        self.iconWidth = 35

        self.textColor = selectedStateColor

        self.lineColor = normalStateColor
        self.titleColor = normalStateColor
        self.iconColor = normalStateColor

        self.selectedLineColor = selectedStateColor
        self.selectedTitleColor = selectedStateColor
        self.selectedIconColor = selectedStateColor
        self.selectedLineHeight = 1.5

        self.backgroundColor = .clear
        self.font = GZEConstants.Font.main
        self.placeholderFont = self.font?.increase(by: 0)
    }
}
