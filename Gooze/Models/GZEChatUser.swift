//
//  GZEChatUser.swift
//  Gooze
//
//  Created by Yussel on 4/4/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Gloss

class GZEChatUser: GZEUserConvertible, Glossy {

    let id: String
    let username: String
    let searchPic: GZEUser.Photo?

    let dateLocation: GZEUser.GeoPoint?

    // Ratings
    var imagesRating: Float?
    var complianceRating: Float?
    var dateQualityRating: Float?
    var dateRating: Float?
    var goozeRating: Float?

    var overallRating: Float? {
        let rates = [Float?](arrayLiteral:
            self.imagesRating,
            self.complianceRating,
            self.dateQualityRating,
            self.dateRating,
            self.goozeRating
            ).flatMap{ $0 }

        guard rates.count > 0 else {
            return nil
        }

        let avg = rates.reduce(0, +) / Float(rates.count)

        return  avg
    }

    init(
        id: String,
        username: String,
        searchPic: GZEUser.Photo? = nil,
        dateLocation: GZEUser.GeoPoint? = nil,
        imagesRating: Float? = nil,
        complianceRating: Float? = nil,
        dateQualityRating: Float? = nil,
        dateRating: Float? = nil,
        goozeRating: Float? = nil
    ) {
        self.id = id
        self.username = username
        self.searchPic = searchPic
        self.dateLocation = dateLocation
        self.imagesRating = imagesRating
        self.complianceRating = complianceRating
        self.dateQualityRating = dateQualityRating
        self.dateRating = dateRating
        self.goozeRating = goozeRating

        super.init()
        //log.debug("\(self) init")
    }

    // MARK: - Gloss Deserialization

    required init?(json: JSON) {

        guard
            let id: String = "id" <~~ json,
            let username: String = "username" <~~ json
        else {
            log.debug("Unable to instantiate, missing required property: \(json)")
            return nil
        }

        self.id = id
        self.username = username
        self.searchPic = "searchPic" <~~ json

        self.dateLocation = "dateLocation" <~~ json

        self.imagesRating = "imagesRating" <~~ json
        self.complianceRating = "complianceRating" <~~ json
        self.dateQualityRating = "dateQualityRating" <~~ json
        self.dateRating = "dateRating" <~~ json
        self.goozeRating = "goozeRating" <~~ json

        super.init()
        //log.debug("\(self) init")
    }

    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "username" ~~> self.username,
            "searchPic" ~~> self.searchPic,

            "dateLocation" ~~> self.dateLocation,

            "imagesRating" ~~> self.imagesRating,
            "complianceRating" ~~> self.complianceRating,
            "dateQualityRating" ~~> self.dateQualityRating,
            "dateRating" ~~> self.dateRating,
            "goozeRating" ~~> self.goozeRating,
            ])
    }
    
    // MARK: - GZEUserConvertible
    override func getUser() -> GZEChatUser {
        return self
    }

    // MARK: - deinitializer
    deinit {
        //log.debug("\(self) disposed")
    }
}


// MARK: Hashable

extension GZEChatUser {
    override var hashValue: Int {
        return  self.id.hashValue
    }
}

// MARK: Equatable

func ==(lhs: GZEChatUser, rhs: GZEChatUser) -> Bool {
    return lhs.id == rhs.id
}
