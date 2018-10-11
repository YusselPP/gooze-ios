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
    case requestAlreadySent = "DATE_REQUEST_ALREADY_SENT"
    case invalidSatus = "REQUEST_INVALID_STATUS"
    case noAck
    
    case unexpected
}


extension DatesSocketError: LocalizedError {
    public var errorDescription: String? {
        
        var message: String
        
        switch self {
        case .paymentMethodRequired:
            message = "error.socket.dates.paymentMethodRequired"
        case .requestAlreadySent:
            message = "error.socket.dates.requestAlreadySent"
        case .invalidSatus:
            message = "error.socket.dates.invalidSatus"
        case .noAck:
            message = "error.socket.dates.noAck"
        case .unexpected:
            message = "error.socket.dates.unexpected"
        }
        return message.localized()
    }
}
