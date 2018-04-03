//
//  ChatSocketError.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/1/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

enum ChatSocketError: String {
    case none
}


extension ChatSocketError: LocalizedError {
    public var errorDescription: String? {
        
        var message: String
        
        switch self {
        case .none:
            message = "".localized()
        }
        return message
    }
}
