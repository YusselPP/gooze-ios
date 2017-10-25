//
//  GZERepositoryError.swift
//  Gooze
//
//  Created by Yussel on 10/23/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import Localize_Swift

enum GZERepositoryError: Error {
    case BadRequest(message: String)
    case ModelNotFound
    case InvalidResponseFormat
}

extension GZERepositoryError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .BadRequest(let message):
            return message.localized()
        case .ModelNotFound:
            return "Model not found"
        case .InvalidResponseFormat:
            return "Invalid response format"
        }
    }
}
