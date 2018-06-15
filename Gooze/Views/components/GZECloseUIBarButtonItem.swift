//
//  GZECloseUIBarButtonItem.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/13/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZECloseUIBarButtonItem: GZENavButton {
    override init() {
        super.init()
        let image = #imageLiteral(resourceName: "nav-close-button")
        button.frame = CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height)
        button.setImage(image, for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
