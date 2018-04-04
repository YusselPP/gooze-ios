//
//  GZEChat.swift
//  Gooze
//
//  Created by Yussel on 4/3/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Gloss

class GZEChat: NSObject, Glossy {

    let id: String
    let ownerId: String
    let recipientId: String

    // let isDeleted: Bool
    init(id: String, ownerId: String, recipientId: String) {
        self.id = id
        self.ownerId = ownerId
        self.recipientId = recipientId
    }

    required init?(json: JSON) {
        guard
            let id: String = "id" <~~ json,
            let ownerId: String = "ownerId" <~~ json,
            let recipientId: String = "recipientId" <~~ json
            else {
                log.debug("Unable to instantiate. Missing required parameter: \(json)")
                return nil
        }

        self.id = id
        self.ownerId = ownerId
        self.recipientId = recipientId
    }

    func toJSON() -> JSON? {
        return jsonify([
            "ownerId" ~~> self.ownerId,
            "recipientId" ~~> self.recipientId,
            ])
    }
}

// MARK: Hashable

extension GZEChat {
    override var hashValue: Int {
        return  self.id.hashValue
    }
}

// MARK: Equatable

func ==(lhs: GZEChat, rhs: GZEChat) -> Bool {
    return lhs.id == rhs.id
}
