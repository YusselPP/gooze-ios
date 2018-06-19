//
//  GZEError.swift
//  Gooze
//
//  Created by Yussel on 11/14/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation

enum GZEError: Error {
    case validation(error: GZEValidationError)
    case repository(error: GZERepositoryError)
    case datesSocket(error: DatesSocketError)
    case chatSocket(error: ChatSocketError)
    case payment(error: GZEPaymentError)
    case conektaToken(error: GZEConektaTokenError)
    case facebookError(error: Error)
}

extension GZEError: LocalizedError {
    public var errorDescription: String? {
        var message: String

        switch self {
        case .validation(let error):
            message = error.localizedDescription

        case .repository(let error):
            message = error.localizedDescription
            
        case .datesSocket(let error):
            message = error.localizedDescription
        case .chatSocket(let error):
            message = error.localizedDescription
        case .payment(let error):
            message = error.localizedDescription
        case .conektaToken(let error):
            message = error.messageToPurchaser ?? "Unexpected Error".localized()
        case .facebookError(let error):
            message = error.localizedDescription
        }
        
        return message
    }
}
