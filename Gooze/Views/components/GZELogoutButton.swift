//
//  GZELogoutButton.swift
//  Gooze
//
//  Created by Yussel on 11/29/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

class GZELogoutButton: GZENavButton {

    override init() {
        super.init()
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        button.frame = CGRect(x: 0.0, y: 0.0, width: 10, height: 10)
        button.setImage(#imageLiteral(resourceName: "exit-icon"), for: .normal)
    }
}
