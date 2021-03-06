//
//  GZEDate.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/25/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import Gloss

class GZEDate: NSObject, Glossy {
    enum Status: String {
        case route
        case starting
        case progress
        case ending
        case ended
        case canceled

        var localizedDescription: String {
            var desc: String

            switch self {
            case .route:
                desc = "model.date.status.route"
            case .starting:
                desc = "model.date.status.starting"
            case .progress:
                desc = "model.date.status.progress"
            case .ending:
                desc = "model.date.status.ending"
            case .ended:
                desc = "model.date.status.ended"
            case .canceled:
                desc = "model.date.status.canceled"
            }

            return desc.localized()
        }
    }
    let id: String
    let status: GZEDate.Status
    let senderStarted: Bool
    let recipientStarted: Bool
    let senderEnded: Bool
    let recipientEnded: Bool
    let senderCanceled: Bool
    let recipientCanceled: Bool
    let createdAt: Date

    // let isDeleted: Bool
    init(id: String, status: GZEDate.Status, senderStarted: Bool, recipientStarted: Bool, senderEnded: Bool, recipientEnded: Bool, senderCanceled: Bool, recipientCanceled: Bool, createdAt: Date) {
        self.id = id
        self.status = status
        self.senderStarted = senderStarted
        self.recipientStarted = recipientStarted
        self.senderEnded = senderEnded
        self.recipientEnded = recipientEnded
        self.senderCanceled = senderCanceled
        self.recipientCanceled = recipientCanceled
        self.createdAt = createdAt
    }

    required init?(json: JSON) {
        guard
            let id: String = "id" <~~ json,
            let status: GZEDate.Status = "status" <~~ json,
            let senderStarted: Bool = "senderStarted" <~~ json,
            let recipientStarted: Bool = "recipientStarted" <~~ json,
            let senderEnded: Bool = "senderEnded" <~~ json,
            let recipientEnded: Bool = "recipientEnded" <~~ json,
            let senderCanceled: Bool = "senderCanceled" <~~ json,
            let recipientCanceled: Bool = "recipientCanceled" <~~ json,
            let createdAt: Date = Decoder.decode(dateForKey: "createdAt", dateFormatter: GZEApi.dateFormatter)(json)
            else {
                log.debug("Unable to instantiate. Missing required parameter: \(json)")
                return nil
        }

        self.id = id
        self.status = status
        self.senderStarted = senderStarted
        self.recipientStarted = recipientStarted
        self.senderEnded = senderEnded
        self.recipientEnded = recipientEnded
        self.senderCanceled = senderCanceled
        self.recipientCanceled = recipientCanceled
        self.createdAt = createdAt
    }

    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "status" ~~> self.status,
            "senderStarted" ~~> self.senderStarted,
            "recipientStarted" ~~> self.recipientStarted,
            "senderEnded" ~~> self.senderEnded,
            "recipientEnded" ~~> self.recipientEnded,
            "senderCanceled" ~~> self.senderCanceled,
            "recipientCanceled" ~~> self.recipientCanceled,
            "createdAt" ~~> Encoder.encode(dateForKey: "createdAt", dateFormatter: GZEApi.dateFormatter)(self.createdAt)
            ])
    }
}

// MARK: Hashable

extension GZEDate {
    override var hashValue: Int {
        return self.id.hashValue
    }
}

// MARK: Equatable

func ==(lhs: GZEDate, rhs: GZEDate) -> Bool {
    return lhs.id == rhs.id
}
