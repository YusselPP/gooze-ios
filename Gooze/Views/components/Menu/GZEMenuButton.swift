//
//  GZEMenuButton.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/18/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEMenuButton: GZENavButton {
    override init() {
        super.init()

        //button.imageView?.contentMode = .center
        button.frame = CGRect(x: 0.0, y: 0.0, width: 34, height: 44)
        button.setImage(#imageLiteral(resourceName: "logo-menu"), for: .normal)

        pp_addBadge(withNumber: 0)
        pp_moveBadgeWith(x: 1, y: 9)
        pp_setBadgeLabelAttributes{label in
            label?.backgroundColor = GZEConstants.Color.mainGreen
            label?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
