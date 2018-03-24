//
//  GZEAccesToken.swift
//  Gooze
//
//  Created by Yussel on 10/30/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import Gloss

struct GZEAccesToken: Glossy {

    let id: String
    let ttl: Int
    let userId: String
    let created: Date
    let expires: Date

    let user: GZEUser

    var isExpired: Bool {
        log.debug("token.ttl: \(self.ttl), token.created: \(self.created), token.expires: \(self.expires)")
        return self.expires.compare(Date()) == .orderedAscending
    }

    init(id: String, ttl: Int, userId: String, created: Date, expires: Date, user: GZEUser) {
        self.id = id
        self.ttl = ttl
        self.userId = userId
        self.created = created
        self.expires = expires
        self.user = user
    }

    init?(json: JSON) {
        guard
            let id: String = "id" <~~ json,
            let ttl: Int = "ttl" <~~ json,
            let userId: String = "userId" <~~ json,
            let user: GZEUser = "user" <~~ json,
            let created = Decoder.decode(dateForKey: "created", dateFormatter: GZEApi.dateFormatter)(json),
            let expires = Decoder.decode(dateForKey: "expires", dateFormatter: GZEApi.dateFormatter)(json)
        else { return nil }

        self.init(id: id, ttl: ttl, userId: userId, created: created, expires: expires, user: user)
    }

    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "ttl" ~~> self.ttl,
            "userId" ~~> self.userId,
            //"user" ~~> self.user,
            Encoder.encode(dateForKey: "created", dateFormatter: GZEApi.dateFormatter)(self.created),
            Encoder.encode(dateForKey: "expires", dateFormatter: GZEApi.dateFormatter)(self.expires)
        ])
    }
}
