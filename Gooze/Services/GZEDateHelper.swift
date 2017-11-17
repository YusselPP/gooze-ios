//
//  GZEDateHelper.swift
//  Gooze
//
//  Created by Yussel on 11/16/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation

class GZEDateHelper {

    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }
}
