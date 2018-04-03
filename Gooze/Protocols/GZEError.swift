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
        }
        
        return message
    }
}
