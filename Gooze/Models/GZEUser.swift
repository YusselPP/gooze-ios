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

class GZEUser: LBModel {

    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter
    }
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

    struct GeoPoint {
        let lat: Float
        let lng: Float
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
    var photos: [String]?

    var currentLocation: GeoPoint?
    var registerCode: String?
    var invitedBy: String?

    var mode: Mode?
    var status: Status?
    var loggedIn: Bool?
    var createdAt: Date?
    var updatedAt: Date?



    // MARK: - Gloss Deserialization
    init?(json: JSON) {

        super.init()
        self.id = "id" <~~ json
        self.username = "username" <~~ json
        self.email = "email" <~~ json

        self.createdAt = Decoder.decode(dateForKey: "createdAt", dateFormatter: GZEUser.dateFormatter)(json)
        self.updatedAt = Decoder.decode(dateForKey: "updatedAt", dateFormatter: GZEUser.dateFormatter)(json)
    }

    override init!(repository: SLRepository!, parameters: [AnyHashable : Any]!) {
        super.init()
    }
}
