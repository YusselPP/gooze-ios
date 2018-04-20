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
    let chatId: String
    let text: String
    //let sender: GZEChatUser
    let senderId: String
    //let recipientId: String
    //let recipient: GZEChatUser
    let type: MessageType
    let status: Status

    let createdAt: Date
    let updatedAt: Date


    var isInfo: Bool {
        return self.type == .info
    }

    // MARK: - init
    // new user message
    init(text: String, senderId: String, chatId: String/*, recipientId: String, sender: GZEChatUser, recipient: GZEChatUser*/) {
        self.id = nil
        self.text = text
        // self.sender = sender
        // self.recipient = recipient
        self.senderId = senderId
        self.chatId = chatId
        //self.recipientId = recipientId
        self.type = .user
        self.status = .sent
        self.createdAt = Date()
        self.updatedAt = Date()
        super.init()
    }

    // new message
    init(text: String, senderId: String, chatId: String/*, recipientId: String sender: GZEChatUser, recipient: GZEChatUser*/, type: MessageType) {
        self.id = nil
        self.text = text
        // self.sender = sender
        // self.recipient = recipient
        self.senderId = senderId
        self.chatId = chatId
        //self.recipientId = recipientId
        self.type = type
        self.status = .sent
        self.createdAt = Date()
        self.updatedAt = Date()
        super.init()
    }

    // Existing message
    init(id: String, text: String, senderId: String, chatId: String/*, recipientId: String sender: GZEChatUser, recipient: GZEChatUser*/, type: MessageType, status: Status, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.text = text
        // self.sender = sender
        // self.recipient = recipient
        self.senderId = senderId
        self.chatId = chatId
        //self.recipientId = recipientId
        self.type = type
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        super.init()
    }

    // Message from json
    required init?(json: JSON) {
        guard
            let text: String = "text" <~~ json,
            //let sender: GZEChatUser = "sender" <~~ json,
            //let recipient: GZEChatUser = "recipient" <~~ json,
            let senderId: String = "senderId" <~~ json,
            let chatId: String = "chatId" <~~ json,
            //let recipientId: String = "recipientId" <~~ json,
            let type: MessageType = "type" <~~ json,
            let status: Status = "status" <~~ json,
            let createdAt: Date = Decoder.decode(dateForKey: "createdAt", dateFormatter: GZEApi.dateFormatter)(json),
            let updatedAt: Date = Decoder.decode(dateForKey: "updatedAt", dateFormatter: GZEApi.dateFormatter)(json)
        else {
            log.debug("Unable to instantiate. Missing required parameter: \(json)")
            return nil
        }

        self.id = "id" <~~ json
        self.text = text
        //self.sender = sender
        //self.recipient = recipient
        self.senderId = senderId
        self.chatId = chatId
        //self.recipientId = recipientId
        self.type = type
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt

        super.init()

        // log.debug("\(self) init")
    }

    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "text" ~~> self.text,
            //"sender" ~~> self.sender,
            //"recipient" ~~> self.recipient,
            "senderId" ~~> self.senderId,
            "chatId" ~~> self.chatId,
            //"recipientId" ~~> self.recipientId,
            "type" ~~> self.type,
            "status" ~~> self.status,
            Encoder.encode(dateForKey: "createdAt", dateFormatter: GZEApi.dateFormatter)(self.createdAt),
            Encoder.encode(dateForKey: "updatedAt", dateFormatter: GZEApi.dateFormatter)(self.updatedAt),
        ])
    }

    func sent(by user: GZEChatUser?) -> Bool {
        guard let user = user else {
            return false
        }
        return self.senderId == user.id
    }
    
    func localizedText() -> String {
        var text = self.text
        
        if self.type == .info {
            
            var textArr = text.split(separator: ",").map{String($0)}
            
            let textKey = textArr.remove(at: 0)
            
            text = String(format: String(textKey).localized(), arguments: textArr as [CVarArg])
        }
        
        return text
    }

    // MARK: - Deinitializer
    deinit {
        //log.debug("\(self) disposed")
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

