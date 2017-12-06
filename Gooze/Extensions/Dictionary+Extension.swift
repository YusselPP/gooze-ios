//
//  Dictionary+Extension.swift
//  Gooze
//
//  Created by Yussel Paredes on 12/5/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation

extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
}
