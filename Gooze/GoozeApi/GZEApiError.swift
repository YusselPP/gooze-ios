//
//  GZEApiError.swift
//  Gooze
//
//  Created by Yussel Paredes on 10/30/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import Localize_Swift
import Gloss

struct GZEApiError: Glossy {

    let statusCode: Int?
    let name: String?
    let message: String?
    let details: GZEApiErrorDetail?

    init?(json: JSON) {
        self.statusCode = "statusCode" <~~ json
        self.name = "name" <~~ json
        self.message = "message" <~~ json
        self.details = "details" <~~ json
    }

    func toJSON() -> JSON? {
        return jsonify([

        ])
    }

    func getMessage() -> String {
        if let message = self.details?.getMessage() {
            return message
        } else if let message = self.message {
            return message.localized()
        } else {
            return ""
        }
    }
}

struct GZEApiErrorDetail: Glossy {

    let context: String?
    let codes: Dictionary<String, Array<String>>?
    let messages: Dictionary<String, Array<String>>?

    init?(json: JSON) {
        self.context = "context" <~~ json
        self.codes = json["codes"] as? Dictionary<String, Array<String>>
        self.messages = json["messages"] as? Dictionary<String, Array<String>>
    }

    func toJSON() -> JSON? {
        return jsonify([

            ])
    }

    func getMessage () -> String {
        var message = ""

        guard let messages = self.messages else {
            return message
        }

        for (field, value) in messages {
            if let localizedValue = value.first?.localized() {
                message += field.localized() + " " + localizedValue + ".\r\n"
            }
        }
        log.debug(message)
        return message
    }
}
