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

    init?(json: JSON) {
        guard
            let id: String = "id" <~~ json,
            let ttl: Int = "ttl" <~~ json,
            let userId: String = "userId" <~~ json,
            let created = Decoder.decode(dateForKey: "created", dateFormatter: GZEApi.dateFormatter)(json)
        else { return nil }

        self.id = id
        self.ttl = ttl
        self.userId = userId
        self.created = created
    }

    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "ttl" ~~> self.ttl,
            "userId" ~~> self.userId,
            Encoder.encode(dateForKey: "created", dateFormatter: GZEApi.dateFormatter)(self.created)
        ])
    }
}
