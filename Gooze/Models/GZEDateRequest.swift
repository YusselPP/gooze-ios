//
//  GZEDateRequest.swift
//  Gooze
//
//  Created by Yussel on 3/27/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Gloss

class GZEDateRequest: NSObject, Glossy {

    enum Status: String {
        case sent = "sent"
        case received = "received"
        case accepted = "accepted"
        case rejected = "rejected"
    }

    let id: String
    let status: Status
    let sender: GZEChatUser
    let recipient: GZEChatUser

    init(id: String, status: Status, sender: GZEChatUser, recipient: GZEChatUser) {
        self.id = id
        self.status = status
        self.sender = sender
        self.recipient = recipient
    }

    required init?(json: JSON) {
        guard
            let id: String = "id" <~~ json,
            let status: Status = "status" <~~ json,
            let sender: GZEChatUser = "sender" <~~ json,
            let recipient: GZEChatUser = "recipient" <~~ json
        else {
            log.error("Unable to instantiate. JSON doesn't include a required property")
            return nil
        }
        self.id = id
        self.status = status
        self.sender = sender
        self.recipient = recipient
    }

    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "status" ~~> self.status,
            "sender" ~~> self.sender,
            "recipient" ~~> self.recipient,
        ]);
    }
}

// MARK: Hashable

extension GZEDateRequest {
    override var hashValue: Int {
        return self.id.hashValue
    }
}

// MARK: Equatable

func ==(lhs: GZEDateRequest, rhs: GZEDateRequest) -> Bool {
    return lhs.id == rhs.id
}
