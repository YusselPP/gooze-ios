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

    enum Status: String {
        case active
        case closed
    }
    let id: String
    let user1Id: String
    let user2Id: String
    let status: GZEChat.Status

    // let isDeleted: Bool
    init(id: String, user1Id: String, user2Id: String, status: GZEChat.Status) {
        self.id = id
        self.user1Id = user1Id
        self.user2Id = user2Id
        self.status = status
    }

    required init?(json: JSON) {
        guard
            let id: String = "id" <~~ json,
            let user1Id: String = "user1Id" <~~ json,
            let user2Id: String = "user2Id" <~~ json,
            let status: GZEChat.Status = "status" <~~ json
            else {
                log.debug("Unable to instantiate. Missing required parameter: \(json)")
                return nil
        }

        self.id = id
        self.user1Id = user1Id
        self.user2Id = user2Id
        self.status = status
    }

    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "user1Id" ~~> self.user1Id,
            "user2Id" ~~> self.user2Id,
            "status" ~~> self.status,
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
