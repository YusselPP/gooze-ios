//
//  Date+Extension.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 11/8/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

extension Date {
    func add(day: Int? = nil, month: Int? = nil, year: Int? = nil) -> Date? {
        var dateComponents = DateComponents()

        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year

        return Calendar.current.date(byAdding: dateComponents, to: self)
    }
}
