//
//  Float+Extension.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/22/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

extension Float {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
