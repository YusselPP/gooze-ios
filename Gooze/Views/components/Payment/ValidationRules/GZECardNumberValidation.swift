//
//  GZECardNumberValidation.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/28/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Validator

struct GZECardNumberValidation: ValidationRule {
    typealias InputType = String

    public var error: Error {
        return self.cardValidation.error
    }

    let cardValidation: ValidationRulePaymentCard

    public init(acceptedTypes: [PaymentCardType], error: Error) {
        self.cardValidation = ValidationRulePaymentCard(acceptedTypes: acceptedTypes, error: error)
    }

    public init(error: Error) {
        self.init(acceptedTypes: PaymentCardType.all, error: error)
    }

    func validate(input: String?) -> Bool {
        return self.cardValidation.validate(input: input?.cardNumberFormat(reverse: true))
    }
}
