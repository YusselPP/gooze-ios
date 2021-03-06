//
//  DatesSocketError.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/1/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

enum DatesSocketError: String {
    case paymentMethodRequired = "PAYMENT_METHOD_REQUIRED"
    case payPalAccountRequired = "PAY_PAL_ACCOUNT_REQUIRED"
    case requestAlreadySent = "DATE_REQUEST_ALREADY_SENT"
    case invalidSatus = "REQUEST_INVALID_STATUS"
    // case incompleteProfile = "USER_INCOMPLETE_PROFILE"
    case noAck
    
    case unexpected
}


extension DatesSocketError: LocalizedError {
    public var errorDescription: String? {
        
        var message: String
        
        switch self {
        case .paymentMethodRequired:
            message = "error.socket.dates.paymentMethodRequired"
        case .payPalAccountRequired:
            message = "error.socket.dates.payPalAccountRequired"
        case .requestAlreadySent:
            message = "error.socket.dates.requestAlreadySent"
        case .invalidSatus:
            message = "error.socket.dates.invalidSatus"
        //case .incompleteProfile:
          //  message = "validation.profile.incomplete"
        case .noAck:
            message = "error.socket.dates.noAck"
        case .unexpected:
            message = "error.socket.dates.unexpected"
        }
        return message.localized()
    }
}
