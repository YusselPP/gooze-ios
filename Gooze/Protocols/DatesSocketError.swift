//
//  DatesSocketError.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/1/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

enum DatesSocketError: String {
    case requestAlreadySent = "DATE_REQUEST_ALREADY_SENT"
    
    case unexpected
}


extension DatesSocketError: LocalizedError {
    public var errorDescription: String? {
        
        var message: String
        
        switch self {
        case .requestAlreadySent:
            message = "error.socket.dates.requestAlreadySent".localized()
        case .unexpected:
            message = "error.socket.dates.unexpected".localized()
        }
        return message
    }
}
