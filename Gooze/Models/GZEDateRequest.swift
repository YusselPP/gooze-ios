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
        case onDate = "onDate"
        case rejected = "rejected"
        case ended = "ended"
        //case canceled = "canceled"
    }

    let id: String
    let status: Status
    let sender: GZEChatUser
    let recipient: GZEChatUser
    let location: GZEUser.GeoPoint
    let chat: GZEChat?
    let amount: Decimal?
    let date: GZEDate?
    let senderClosed: Bool
    let recipientClosed: Bool
    let shownInSenderHistory: Bool
    let shownInRecipientHistory: Bool
    let transaction: GZETransaction?

    var isBlocked: Bool {
        return self.status != .accepted && self.status != .onDate
    }

    init(id: String, status: Status, sender: GZEChatUser, recipient: GZEChatUser, location: GZEUser.GeoPoint, chat: GZEChat? = nil, amount: Decimal? = nil, date: GZEDate? = nil, senderClosed: Bool, recipientClosed: Bool, shownInSenderHistory: Bool, shownInRecipientHistory: Bool, transaction: GZETransaction? = nil) {
        self.id = id
        self.status = status
        self.sender = sender
        self.recipient = recipient
        self.location = location
        self.chat = chat
        self.amount = amount
        self.date = date
        self.senderClosed = senderClosed
        self.recipientClosed = recipientClosed
        self.shownInSenderHistory = shownInSenderHistory
        self.shownInRecipientHistory = shownInRecipientHistory
        self.transaction = transaction
        super.init()
    }

    required init?(json: JSON) {
        guard
            let id: String = "id" <~~ json,
            let status: Status = "status" <~~ json,
            let sender: GZEChatUser = "sender" <~~ json,
            let recipient: GZEChatUser = "recipient" <~~ json,
            let location: GZEUser.GeoPoint = "location" <~~ json,
            let senderClosed: Bool = "senderClosed" <~~ json,
            let recipientClosed: Bool = "recipientClosed" <~~ json,
            let shownInSenderHistory: Bool = "shownInSenderHistory" <~~ json,
            let shownInRecipientHistory: Bool = "shownInRecipientHistory" <~~ json
        else {
            log.error("Unable to instantiate. JSON doesn't include a required property")
            return nil
        }


        if let amountString: String = "amount" <~~ json {
            log.debug("json amount: \(amountString)")
            let decimalAmount = Decimal(string: amountString)
            self.amount = decimalAmount
            log.debug("parsed decimal amount: \(String(describing: decimalAmount))")
        } else {
            self.amount = nil
        }

        self.id = id
        self.status = status
        self.sender = sender
        self.recipient = recipient
        self.location = location
        self.chat = "chat" <~~ json
        self.date = "date" <~~ json
        self.senderClosed = senderClosed
        self.recipientClosed = recipientClosed
        self.shownInSenderHistory = shownInSenderHistory
        self.shownInRecipientHistory = shownInRecipientHistory
        self.transaction = "transaction" <~~ json
        super.init()
    }

    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "status" ~~> self.status,
            "sender" ~~> self.sender,
            "recipient" ~~> self.recipient,
            "location" ~~> self.location,
            "chat" ~~> self.chat,
            "amount" ~~> self.amount?.description,
            "date" ~~> self.date,
            "senderClosed" ~~> self.senderClosed,
            "recipientClosed" ~~> self.recipientClosed,
            "shownInSenderHistory" ~~> self.shownInSenderHistory,
            "shownInRecipientHistory" ~~> self.shownInRecipientHistory,
        ]);
    }

    func hasFinishedState() -> Bool {
        switch self.status {
        case .ended,
             //.canceled,
             .rejected:
            return true
        case .sent,
             .received,
             .accepted,
             .onDate:
            return false
        }
    }

    func getUserMode(_ aUser: GZEUser) -> GZEChatViewMode? {
        if aUser.id == self.sender.id {
            return .client
        } else if aUser.id == self.recipient.id {
            return .gooze
        }

        return nil
    }
    
    // MARK: - GZEUserConvertible
    enum UserMode {
        case sender
        case recipient
    }
    var userMode = UserMode.sender
    
    override func getUser() -> GZEChatUser {
        if let authUserId = GZEAuthService.shared.authUser?.id {
            if authUserId == self.sender.id {
                return self.recipient
            } else {
                return self.sender
            }
        }

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
