//
//  GZEValidationError.swift
//  Gooze
//
//  Created by Yussel Paredes on 11/10/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import Localize_Swift

enum GZEValidationError: Error {
    case required(fieldName: String)

    case invalidEmail
    case invalidNumber(fieldName: String)

    case lengthMin(fieldName: String, min: Int)
    case lengthMax(fieldName: String, max: Int)
    case exists(fieldName: String)

    case underAge
}

extension GZEValidationError: LocalizedError {
    public var errorDescription: String? {

        var message: String

        switch self {
        case .required(let fieldName):
            message = "validation.required".localized()
            message = String(format: message, fieldName)

        case .invalidEmail:
            message = "validation.invalidEmail".localized()
        case .invalidNumber(let fieldName):
            message = "validation.invalidNumber".localized()
            message = String(format: message, fieldName)

        case .lengthMin(let fieldName, let min):
            message = "validation.lengthMin".localized()
            message = String(format: message, fieldName, min)

        case .lengthMax(let fieldName, let max):
            message = "validation.lengthMax".localized()
            message = String(format: message, fieldName, max)

        case .exists(let fieldName):
            message = "validation.exists".localized()
            message = String(format: message, fieldName)

        case .underAge:
            message = "validation.underAge".localized()
        }
        return message
    }
}
