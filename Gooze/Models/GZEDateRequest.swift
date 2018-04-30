//
//  GZEDateRequest.swift
//  Gooze
//
//  Created by Yussel on 3/27/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Gloss

class GZEDateRequest: GZEUserConvertible, Glossy {

    enum Status: String {
        case sent = "sent"
        case received = "received"
        case accepted = "accepted"
        case rejected = "rejected"
        case ended = "ended"
    }

    let id: String
    let status: Status
    let sender: GZEChatUser
    let recipient: GZEChatUser
    let chat: GZEChat?
    let amount: Double?
    let date: GZEDate?

    init(id: String, status: Status, sender: GZEChatUser, recipient: GZEChatUser, chat: GZEChat? = nil, amount: Double? = nil, date: GZEDate? = nil) {
        self.id = id
        self.status = status
        self.sender = sender
        self.recipient = recipient
        self.chat = chat
        self.amount = amount
        self.date = date
        super.init()
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
        self.chat = "chat" <~~ json
        self.amount = "amount" <~~ json
        self.date = "date" <~~ json
        super.init()
    }

    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "status" ~~> self.status,
            "sender" ~~> self.sender,
            "recipient" ~~> self.recipient,
            "chat" ~~> self.chat,
            "amount" ~~> self.amount,
            "date" ~~> self.date,
        ]);
    }
    
    // MARK: - GZEUserConvertible
    enum UserMode {
        case sender
        case recipient
    }
    var userMode = UserMode.sender
    
    override func getUser() -> GZEChatUser {
        switch self.userMode {
        case .recipient:
            return self.recipient
        case .sender:
            return self.sender
        }
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
    log.debug("equals called")
    return lhs.id == rhs.id
}

func ==(lhs: GZEDateRequest?, rhs: GZEDateRequest?) -> Bool {
    log.debug("optional equals called")
    if let lhs = lhs, let rhs = rhs {
        return lhs.id == rhs.id
    } else {
        return false
    }
}
