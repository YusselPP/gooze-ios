//
//  GZEConektaTokenError.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/29/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Gloss

class GZEConektaTokenError: Error, Glossy {
    enum Types: String {
        case parameterValidationError = "parameter_validation_error"
    }

    enum Codes: String {
        case invalidExpiryMonth = "invalid_expiry_month"
        case invalidExpiryYear = "invalid_expiry_year"
        case expiredCard = "expired_card"
        case invalidNumber = "invalid_number"
    }

    let type: Types?
    let code: Codes?

    let message: String?
    let messageToPurchaser: String?

    let param: String?
    let validationError: String?

    init(
        type: Types?,
        code: Codes?,

        message: String,
        messageToPurchaser: String,

        param: String,
        validationError: String?
        ) {
        self.type = type
        self.code = code
        self.message = message
        self.messageToPurchaser = messageToPurchaser
        self.param = param
        self.validationError = validationError
    }

    required init?(json: JSON) {
//        guard
//            let type: Types = "type" <~~ json,
//            let code: Codes = "code" <~~ json
//        else {
//                log.debug("Unable to instantiate. Missing required parameter: \(json)")
//                return nil
//        }

        self.type = "type" <~~ json
        self.code = "code" <~~ json
        self.message = "messages" <~~ json
        self.messageToPurchaser = "message_to_purchaser" <~~ json
        self.param = "param" <~~ json
        self.validationError = "validation_error" <~~ json
    }

    func toJSON() -> JSON? {
        return jsonify([
            "type" ~~> self.type,
            "code" ~~> self.code,
            "message" ~~> self.message,
            "message_to_purchaser" ~~> self.messageToPurchaser,
            "param" ~~> self.param,
            ])
    }
}
