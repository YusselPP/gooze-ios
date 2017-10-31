//
//  GZEUser.swift
//  Gooze
//
//  Created by Yussel on 10/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import Gloss
import LoopBack
import Alamofire
import ReactiveSwift


class GZEUser: Glossy {

    enum Gender: String {
        case male = "male"
        case female = "female"
        case other = "other"
    }

    enum Status: String {
        case available = "available"
        case unavailable = "unavailable"
    }

    enum Mode: String {
        case client = "client"
        case gooze = "gooze"
    }

    struct GeoPoint: Glossy {
        let lat: Float
        let lng: Float

        init?(json: JSON) {
            guard
                let lat: Float = "lat" <~~ json,
                let lng: Float = "lng" <~~ json else {

                return nil
            }

            self.lat = lat
            self.lng = lng
        }

        func toJSON() -> JSON? {
            return jsonify([
                "lat" ~~> self.lat,
                "lng" ~~> self.lng
            ])
        }
    }

    struct Photo: Glossy {
        let image: String
        let blocked: Bool

        init?(json: JSON) {
            guard
                let image: String = "image" <~~ json,
                let blocked: Bool = "blocked" <~~ json else {

                    return nil
            }
            self.image = image
            self.blocked = blocked
        }

        func toJSON() -> JSON? {
            return jsonify([
                "image" ~~> self.image,
                "blocked" ~~> self.blocked
                ])
        }
    }

    // Mark: Instance members
    var id: String?

    var username: String?
    var email: String?
    var password: String?

    var birthday: Date?
    var gender: Gender?
    var weight: Float?
    var height: Float?
    var origin: String?
    var phrase: String?

    var languages: [String]?
    var interestedIn: [String]?
    var photos: [Photo]?

    var currentLocation: GeoPoint?
    var registerCode: String?
    var invitedBy: String?

    var mode: Mode?
    var status: Status?
    var loggedIn: Bool?
    var createdAt: Date?
    var updatedAt: Date?

    init() {
        log.debug("\(self) init")
    }

    // MARK: - Gloss Deserialization

    required init?(json: JSON) {

        self.id = "id" <~~ json

        self.username = "username" <~~ json
        self.email = "email" <~~ json
        self.password = "password" <~~ json

        self.gender = "gender" <~~ json
        self.weight = "weight" <~~ json
        self.height = "height" <~~ json
        self.origin = "origin" <~~ json
        self.phrase = "phrase" <~~ json

        self.languages = "languages" <~~ json
        self.interestedIn = "interestedIn" <~~ json
        self.photos = "photos" <~~ json

        self.currentLocation = "currentLocation" <~~ json
        self.registerCode = "registerCode" <~~ json
        self.invitedBy = "invitedBy" <~~ json

        self.mode = "mode" <~~ json
        self.status = "status" <~~ json
        self.loggedIn = "loggedIn" <~~ json

        self.birthday = Decoder.decode(dateForKey: "birthday", dateFormatter: GZEApi.dateFormatter)(json)
        self.createdAt = Decoder.decode(dateForKey: "createdAt", dateFormatter: GZEApi.dateFormatter)(json)
        self.updatedAt = Decoder.decode(dateForKey: "updatedAt", dateFormatter: GZEApi.dateFormatter)(json)

        log.debug("\(self) init")
    }

    // MARK: - Gloss Serialization

    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,

            "username" ~~> self.username,
            "email" ~~> self.email,
            "password" ~~> self.password,

            "gender" ~~> self.gender,
            "weight" ~~> self.weight,
            "height" ~~> self.height,
            "origin" ~~> self.origin,
            "phrase" ~~> self.phrase,

            "languages" ~~> self.languages,
            "interestedIn" ~~> self.interestedIn,
            "photos" ~~> self.photos,

            "currentLocation" ~~> self.currentLocation,
            "registerCode" ~~> self.registerCode,
            "invitedBy" ~~> self.invitedBy,

            "mode" ~~> self.mode,
            "status" ~~> self.status,
            "loggedIn" ~~> self.loggedIn,

            Encoder.encode(dateForKey: "birthday", dateFormatter: GZEApi.dateFormatter)(self.birthday),
            Encoder.encode(dateForKey: "createdAt", dateFormatter: GZEApi.dateFormatter)(self.createdAt),
            Encoder.encode(dateForKey: "updatedAt", dateFormatter: GZEApi.dateFormatter)(self.updatedAt),
        ])
    }

    // MARK: Deinitializers

    deinit {
        log.debug("\(self) disposed")
    }
}
