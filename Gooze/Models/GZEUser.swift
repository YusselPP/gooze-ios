//
//  GZEUser.swift
//  Gooze
//
//  Created by Yussel on 10/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import Gloss
import Alamofire
import ReactiveSwift
import Validator
import Localize_Swift


class GZEUser: Glossy {

    enum Gender: String {
        case male = "male"
        case female = "female"
        case other = "other"

        static var array: [Gender] {
            var a: [Gender] = []
            switch Gender.male {
            case .male: a.append(.male); fallthrough
            case .female: a.append(.female); fallthrough
            case .other: a.append(.other);
            }
            return a
        }
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
        var url: String?
        var blocked: Bool?
        var image: UIImage?

        init(image: UIImage?) {
            self.image = image
        }

        init?(json: JSON) {
            self.url = "url" <~~ json
            self.blocked = "blocked" <~~ json
        }

        func toJSON() -> JSON? {
            return jsonify([
                "url" ~~> self.url,
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
        // self.photos = "photos" <~~ json

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
            // "photos" ~~> self.photos,

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

    // MARK: Validation

    enum Validation {

        case username
        case email
        case password

        case birthday
        case gender
        case weight
        case height
        case origin
        case phrase

        case language
        case interestedIn

        case registerCode
        case invitedBy

        var fieldName: String {
            switch self {
            case .username:
                return "user.username.fieldName".localized()
            case .email:
                return "user.email.fieldName".localized()
            case .password:
                return "user.password.fieldName".localized()

            case .birthday:
                return "user.birthday.fieldName".localized()
            case .gender:
                return "user.gender.fieldName".localized()
            case .weight:
                return "user.weight.fieldName".localized()
            case .height:
                return "user.height.fieldName".localized()
            case .origin:
                return "user.origin.fieldName".localized()
            case .phrase:
                return "user.phrase.fieldName".localized()

            case .language:
                return "user.language.fieldName".localized()
            case .interestedIn:
                return "user.interestedIn.fieldName".localized()

            case .registerCode:
                return "user.registerCode.fieldName".localized()
            case .invitedBy:
                return "user.invitedBy.fieldName".localized()
            }
        }

        func stringRule() -> ValidationRuleSet<String>? {

            var ruleSet = ValidationRuleSet<String>()

            switch self {
            case .username:
                ruleSet.add(rule: ValidationRuleLength(min: 1, error: GZEValidationError.required(fieldName: fieldName)))
                ruleSet.add(rule: ValidationRuleLength(max: 128, error: GZEValidationError.lengthMax(fieldName: fieldName, max: 128)))
            case .email:
                ruleSet.add(rule: ValidationRuleLength(min: 1, error: GZEValidationError.required(fieldName: fieldName)))
                ruleSet.add(rule: ValidationRulePattern(pattern: EmailValidationPattern.standard, error: GZEValidationError.invalidEmail))
            case .password:
                ruleSet.add(rule: ValidationRuleLength(min: 8, error: GZEValidationError.lengthMin(fieldName: fieldName, min: 8)))

//            case .birthday:
//            case .gender:
//            case .weight:
//            case .height:
//            case .origin:
//            case .phrase:
//
//            case .language:
//            case .interestedIn:
//            
//            case .registerCode:
//            case .invitedBy:
            default:
                log.warning("\(self) doesn't have string rules defined")
                return nil
            }

            return ruleSet
        }
    }

    // MARK: Deinitializers

    deinit {
        log.debug("\(self) disposed")
    }
}
