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

        button.imageView?.contentMode = .center
        button.setImage(#imageLiteral(resourceName: "logo-menu"), for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
