//
//  GZENextUIBarButtonItem.swift
//  Gooze
//
//  Created by Yussel on 2/24/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZENextUIBarButtonItem: GZENavButton {
    override init() {
        super.init()

        button.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 40)
        button.setImage(#imageLiteral(resourceName: "nav-next-button"), for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
