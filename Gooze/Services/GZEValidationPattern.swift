//
//  GZEValidationPattern.swift
//  Gooze
//
//  Created by Yussel on 3/2/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Validator

enum GZEValidationPattern: ValidationPattern {

    case atMost2decimalsOptional

    var pattern: String {
        switch self {
        case .atMost2decimalsOptional: return "^([0-9]+(\\.[0-9]{1,2})?)?$"
        }
    }
}
