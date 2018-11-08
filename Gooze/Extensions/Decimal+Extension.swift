//
//  Decimal+Extension.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 11/7/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

extension Decimal {
    func toCurrencyString() -> String? {
        return GZENumberHelper.shared.currencyFormatter.string(
            from: NSDecimalNumber(decimal: self)
        )
    }
}
