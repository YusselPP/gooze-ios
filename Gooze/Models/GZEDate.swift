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
        case progress
        case canceled
        case ended
    }
    let id: String
    let status: GZEDate.Status

    // let isDeleted: Bool
    init(id: String, status: GZEDate.Status) {
        self.id = id
        self.status = status
    }

    required init?(json: JSON) {
        guard
            let id: String = "id" <~~ json,
            let status: GZEDate.Status = "status" <~~ json
            else {
                log.debug("Unable to instantiate. Missing required parameter: \(json)")
                return nil
        }

        self.id = id
        self.status = status
    }

    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "status" ~~> self.status,
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
