//
//  GZELabel.swift
//  Gooze
//
//  Created by Yussel on 3/5/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZELabel: UILabel {

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
    }

    func setWhiteFontFormat(align: NSTextAlignment = .center) {
        self.font = GZEConstants.Font.main
        self.textColor = UIColor.white
        self.textAlignment = align
    }

}
