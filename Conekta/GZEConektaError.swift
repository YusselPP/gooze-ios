//
//  GZEConektaError.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/29/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

class GZEConektaError: Error {

    enum Types: String {
        case parameterValidationError = "parameter_validation_error"
    }

    enum Codes: String {
        case invalidExpiryYear = "invalid_expiry_year"
    }

    let type: Types
    let details: [GZEConektaErrorDetail]

    init(
        type: Types,
        details: [GZEConektaErrorDetail]
    ) {
        self.type = type
        self.details = details
    }
}
