//
//  GZELogoutButton.swift
//  Gooze
//
//  Created by Yussel on 11/29/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

class GZELogoutButton: UIBarButtonItem {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        image = #imageLiteral(resourceName: "exit-icon")
    }

    override init() {
        super.init()
        
        image = #imageLiteral(resourceName: "exit-icon")
    }
}
