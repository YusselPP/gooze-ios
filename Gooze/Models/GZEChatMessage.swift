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

    enum Status {
        case sent
        case received
        case read
    }

    let chatId: String?
    let text: String
    let senderId: String?
    let recipientId: String?
    let status: Status

    let createdAt: Date


    var isInfo: Bool {
        return self.senderId == nil && self.recipientId == nil
    }

    var hasRecipient: Bool {
        return self.recipientId != nil
    }

    var hasSender: Bool {
        return self.senderId != nil
    }

    var isValid: Bool {
        return self.isInfo || self.hasSender && self.hasRecipient
    }

    // MARK: - init
    // new message
    init(text: String, senderId: String, recipientId: String) {
        self.chatId = nil
        self.text = text
        self.senderId = senderId
        self.recipientId = recipientId
        self.status = .sent
        self.createdAt = Date()
        super.init()
    }

    // Existing message
    init(chatId: String, text: String, senderId: String, recipientId: String, status: Status, createdAt: Date) {
        self.chatId = chatId
        self.text = text
        self.senderId = senderId
        self.recipientId = recipientId
        self.status = status
        self.createdAt = createdAt
        super.init()
    }

    // Message from json
    required init?(json: JSON) {
        guard
            let text: String = "text" <~~ json,
            let status: Status = "status" <~~ json,
            let createdAt: Date = Decoder.decode(dateForKey: "createdAt", dateFormatter: GZEApi.dateFormatter)(json)
        else {
            log.debug("Unable to instantiate. Missing required parameter: \(json)")
            return nil
        }

        self.chatId = "chatId" <~~ json
        self.text = text
        self.senderId = "senderId" <~~ json
        self.recipientId = "recipientId" <~~ json
        self.status = status
        self.createdAt = createdAt

        super.init()

        if !self.isValid {
            log.debug("Unable to instantiate. Invalid json: \(json)")
            return nil
        }

        log.debug("\(self) init")
    }

    func toJSON() -> JSON? {
        return jsonify([
            "text" ~~> self.text,
            "senderId" ~~> self.senderId,
            "recipientId" ~~> self.recipientId,
            "status" ~~> self.status,
            Encoder.encode(dateForKey: "createdAt", dateFormatter: GZEApi.dateFormatter)(self.createdAt),
        ])
    }

    func sent(by userId: String?) -> Bool {
        guard let userId = userId else {
            return false
        }
        return self.senderId == userId
    }

    // MARK: - Deinitializer
    deinit {
        log.debug("\(self) disposed")
    }
}
