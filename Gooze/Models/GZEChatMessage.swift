//
//  GZEChatMessage.swift
//  Gooze
//
//  Created by Yussel on 3/30/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Gloss

class GZEChatMessage: NSObject, Glossy {

    enum Status: String {
        case sent = "sent"
        case received = "received"
        case read = "read"
    }

    enum MessageType: String {
        case info
        case user
    }

    let id: String?
    let text: String
    let sender: GZEChatUser
    let recipient: GZEChatUser
    let type: MessageType
    let status: Status

    let createdAt: Date


    var isInfo: Bool {
        return self.type == .info
    }

    // MARK: - init
    // new user message
    init(text: String, sender: GZEChatUser, recipient: GZEChatUser) {
        self.id = nil
        self.text = text
        self.sender = sender
        self.recipient = recipient
        self.type = .user
        self.status = .sent
        self.createdAt = Date()
        super.init()
    }

    // new message
    init(text: String, sender: GZEChatUser, recipient: GZEChatUser, type: MessageType) {
        self.id = nil
        self.text = text
        self.sender = sender
        self.recipient = recipient
        self.type = type
        self.status = .sent
        self.createdAt = Date()
        super.init()
    }

    // Existing message
    init(id: String, text: String, sender: GZEChatUser, recipient: GZEChatUser, type: MessageType, status: Status, createdAt: Date) {
        self.id = id
        self.text = text
        self.sender = sender
        self.recipient = recipient
        self.type = type
        self.status = status
        self.createdAt = createdAt
        super.init()
    }

    // Message from json
    required init?(json: JSON) {
        guard
            let text: String = "text" <~~ json,
            let sender: GZEChatUser = "sender" <~~ json,
            let recipient: GZEChatUser = "recipient" <~~ json,
            let type: MessageType = "type" <~~ json,
            let status: Status = "status" <~~ json,
            let createdAt: Date = Decoder.decode(dateForKey: "createdAt", dateFormatter: GZEApi.dateFormatter)(json)
        else {
            log.debug("Unable to instantiate. Missing required parameter: \(json)")
            return nil
        }

        self.id = "id" <~~ json
        self.text = text
        self.sender = sender
        self.recipient = recipient
        self.type = type
        self.status = status
        self.createdAt = createdAt

        super.init()

        log.debug("\(self) init")
    }

    func toJSON() -> JSON? {
        return jsonify([
            "text" ~~> self.text,
            "sender" ~~> self.sender,
            "recipient" ~~> self.recipient,
            "type" ~~> self.type,
            "status" ~~> self.status,
            Encoder.encode(dateForKey: "createdAt", dateFormatter: GZEApi.dateFormatter)(self.createdAt),
        ])
    }

    func sent(by user: GZEChatUser?) -> Bool {
        guard let user = user else {
            return false
        }
        return self.sender == user
    }

    // MARK: - Deinitializer
    deinit {
        log.debug("\(self) disposed")
    }
}

// MARK: Hashable

extension GZEChatMessage {
    override var hashValue: Int {
        return self.id?.hashValue ?? 0
    }
}

// MARK: Equatable

func ==(lhs: GZEChatMessage, rhs: GZEChatMessage) -> Bool {
    if let lhsId = lhs.id, let rhsId = rhs.id {
        return lhsId == rhsId
    }
    return false
}

