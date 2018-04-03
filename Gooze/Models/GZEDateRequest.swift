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
    let senderId: String
    let recipientId: String
    let sender: GZEUser
    let recipient: GZEUser?

    init(id: String, status: Status, senderId: String, recipientId: String, sender: GZEUser, recipient: GZEUser? =  nil) {
        self.id = id
        self.status = status
        self.senderId = senderId
        self.recipientId = recipientId
        self.sender = sender
        self.recipient = recipient
    }

    required init?(json: JSON) {
        guard
            let id: String = "id" <~~ json,
            let status: Status = "status" <~~ json,
            let senderId: String = "senderId" <~~ json,
            let recipientId: String = "recipientId" <~~ json,
            let sender: GZEUser = "sender" <~~ json
        else {
            log.error("Unable to instantiate. JSON doesn't include a required property")
            return nil
        }
        self.id = id
        self.status = status
        self.senderId = senderId
        self.recipientId = recipientId
        self.sender = sender
        self.recipient = "recipient" <~~ json
    }

    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "status" ~~> self.status,
            "senderId" ~~> self.senderId,
            "recipientId" ~~> self.recipientId,
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
