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

    static var displayDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter
    }

    static var displayDateTimeFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }

    /// Returns the amount of years from another date
    static func years(from date: Date, to: Date) -> Int {
        return Calendar.current.dateComponents(Set([Calendar.Component.year]), from: date, to: to).year ?? 0
    }
}
