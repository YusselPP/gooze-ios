//
//  GZENumberHelper.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/19/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

class GZENumberHelper {
    
    static let shared = GZENumberHelper()
    
    let currencyFormatter = NumberFormatter()
    
    private init() {
        currencyFormatter.numberStyle = .currency
    }
}
