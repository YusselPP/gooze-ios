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
    let code: String?
    let details: GZEApiErrorDetail?
    let args: [String]

    init?(json: JSON) {
        self.statusCode = "statusCode" <~~ json
        self.name = "name" <~~ json
        self.message = "message" <~~ json
        self.code = "code" <~~ json
        self.details = "details" <~~ json
        self.args = ("args" <~~ json) ?? []
    }

    func toJSON() -> JSON? {
        return jsonify([
            "statusCode" ~~> self.statusCode,
            "name" ~~> self.name,
            "message" ~~> self.message,
            "code" ~~> self.code,
            "details" ~~> self.details
        ])
    }

    func getMessage() -> String {
        if let message = self.details?.getMessage() {
            return message
        } else if let message = self.message {
            return String(format: message.localized(), arguments: self.args.map{$0.localized()})
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
            "context" ~~> self.context,
            "codes" ~~> self.codes,
            "messages" ~~> self.messages
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
