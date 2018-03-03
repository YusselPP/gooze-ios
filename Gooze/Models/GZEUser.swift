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
import CoreLocation


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

        var displayValue: String {
            return self.rawValue.localized().capitalizingFirstLetter()
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
        let lat: Double
        let lng: Double

        init(lat: Double, lng: Double) {
            self.lat = lat
            self.lng = lng
        }

        init(CLCoord: CLLocationCoordinate2D) {
            self.lat = CLCoord.latitude
            self.lng = CLCoord.longitude
        }

        init?(json: JSON) {
            guard
                let lat: Double = "lat" <~~ json,
                let lng: Double = "lng" <~~ json else {

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

        func toCoreLocationCoordinate2D() -> CLLocationCoordinate2D {
            return CLLocationCoordinate2D(latitude: self.lat, longitude: self.lng)
        }
    }

    struct Photo: Glossy {
        static let container = "picture"

        var name: String?
        var container: String?
        var url: String? 
        var blocked: Bool?
        var image: UIImage?

        init?(image: UIImage?) {
            if let image = image {
                self.image = image
            } else {
                return nil
            }
        }

        init?(json: JSON) {
            self.name = "name" <~~ json
            self.container = "container" <~~ json
            self.url = "url" <~~ json
            self.blocked = "blocked" <~~ json
        }

        func toJSON() -> JSON? {
            return jsonify([
                "name" ~~> self.name,
                "container" ~~> self.container,
                "url" ~~> self.url,
                "blocked" ~~> self.blocked
                ])
        }

        var urlRequest: URLRequest? {
            get {
                if let url = self.url {
                    return try? GZEUserRouter.photo(url: url).asURLRequest()
                } else {
                    return nil
                }
            }
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
    var activeUntil: Date?

    var registerCode: String?
    var invitedBy: String?

    var mode: Mode?
    var status: Status?
    var loggedIn: Bool?
    var createdAt: Date?
    var updatedAt: Date?

    var profilePic: Photo?

    var searchPic: Photo?

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
        self.profilePic = "profilePic" <~~ json
        self.searchPic = "searchPic" <~~ json

        self.currentLocation = "currentLocation" <~~ json
        self.activeUntil = Decoder.decode(dateForKey: "activeUntil", dateFormatter: GZEApi.dateFormatter)(json)

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
            // "id" ~~> self.id,

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
            "profilePic" ~~> self.profilePic,
            "searchPic" ~~> self.searchPic,

            "currentLocation" ~~> self.currentLocation,
            Encoder.encode(dateForKey: "activeUntil", dateFormatter: GZEApi.dateFormatter)(self.activeUntil),

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

        case profilePic
        case searchPic
        case galleryPics

        var fieldName: String {
            var key: String
            switch self {
            case .username:
                key = "user.username.fieldName"
            case .email:
                key = "user.email.fieldName"
            case .password:
                key = "user.password.fieldName"

            case .birthday:
                key = "user.birthday.fieldName"
            case .gender:
                key = "user.gender.fieldName"
            case .weight:
                key = "user.weight.fieldName"
            case .height:
                key = "user.height.fieldName"
            case .origin:
                key = "user.origin.fieldName"
            case .phrase:
                key = "user.phrase.fieldName"

            case .language:
                key = "user.language.fieldName"
            case .interestedIn:
                key = "user.interestedIn.fieldName"

            case .registerCode:
                key = "user.registerCode.fieldName"
            case .invitedBy:
                key = "user.invitedBy.fieldName"
            case .profilePic:
                key = "user.profilePic.fieldName"
            case .searchPic:
                key = "user.searchPic.fieldName"
            case .galleryPics:
                key = "user.galleryPics.fieldName"
            }

            return key.localized()
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
            case .weight,
                 .height:
                // ruleSet.add(rule: ValidationRuleComparison<Float>(min: 0, max: , error: GZEValidationError.lengthMin(fieldName: fieldName, min: 0)))
                ruleSet.add(rule: ValidationRulePattern(pattern: GZEValidationPattern.atMost2decimalsOptional, error: GZEValidationError.invalidNumber(fieldName: fieldName)))
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
