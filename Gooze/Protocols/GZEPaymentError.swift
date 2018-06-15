//
//  GZEPaymentError.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/29/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

enum GZEPaymentError: Error {
    case missingRequiredParams
    case paypal(_: Error)
}

extension GZEPaymentError: LocalizedError {
    public var errorDescription: String? {

        var message: String

        switch self {
        case .missingRequiredParams:
            message = "error.payment.missingRequiredParams".localized()
        case .paypal(let error):
            message = error.localizedDescription
        }
        return message
    }
}
