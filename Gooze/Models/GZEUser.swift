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
import AlamofireImage
import ReactiveSwift
import Validator
import Localize_Swift
import CoreLocation


class GZEUser: NSObject, Glossy {

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

        var displayPlural: String {
            return "\(self.rawValue).plural".localized().capitalizingFirstLetter()
        }
    }

    enum Status: String {
        case available = "available"
        case unavailable = "unavailable"
        case onDate = "onDate"
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

        func toCLLocation() -> CLLocation {
            return CLLocation(latitude: self.lat, longitude: self.lng)
        }

        func distance(from: GeoPoint) -> CLLocationDistance {
            return self.toCLLocation().distance(from: from.toCLLocation())
        }
    }

    struct Photo: Glossy {
        static let container = "picture"

        var name: String?
        var container: String?
        var url: String? 
        var blocked: Bool?
        var image: UIImage?

        init() {

        }

        init(image: UIImage?, name: String?) {
            self.image = image
            self.name = name
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

        @discardableResult
        func removeFromCache(_ cache: ImageRequestCache? = ImageDownloader.default.imageCache, withIdentifier identifier: String? = nil) -> Bool {
            guard let cache = cache else {
                log.error("Failed to remove from cache, nil cache storage provided")
                return false
            }

            guard let urlRequest = self.urlRequest else {
                log.error("Failed to remove from cache, nil urlRequest")
                return false
            }

            if cache.removeImage(for: urlRequest, withIdentifier: identifier) {
                log.debug("Succesfully removed from cahche: \(String(describing: urlRequest.url?.relativeString))")
                return true
            } else {
                log.debug("Failed to remove from chach: \(String(describing: urlRequest.url?.relativeString))")
                return false
            }
        }
    }

    struct Comment: Glossy {
        let count: Int
        let comment: GZERateComment

        init?(json: JSON) {
            guard
                let count: Int = "count" <~~ json,
                let comment: GZERateComment = "comment" <~~ json else {
                    log.debug("unable to instantiate. invalid json")
                    return nil
            }

            self.count = count
            self.comment = comment
        }

        func toJSON() -> JSON? {
            return jsonify([
                "count" ~~> self.count,
                "comment" ~~> self.comment
                ])
        }
    }

    static let heightUnit = "m"
    static let weightUnit = "kg"
    static let ageLabel = "vm.user.ageLabel".localized()
    static let ageUnit = "vm.user.ageUnit".localized()

    // Mark: Instance members
    var id: String
    var username: String
    var email: String

    //var password: String?

    var paypalCustomerId: String?
    var payPalEmail: String?

    var birthday: Date?
    var gender: Gender?
    var searchForGender: [Gender]?
    var weight: Float?
    var height: Float?
    var origin: String?
    var phrase: String?

    var languages: [String]?
    var interestedIn: [String]?

    var currentLocation: GeoPoint?
    var currentLoc: [Double]?
    var dateLocation: GeoPoint?
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
    var photos: [Photo]?

    var activeDateRequest: GZEDateRequest?

    // Ratings
    var imagesRating: GZERatings.Rating?
    var complianceRating: GZERatings.Rating?
    var dateQualityRating: GZERatings.Rating?
    var dateRating: GZERatings.Rating?
    var goozeRating: GZERatings.Rating?

    var overallRating: Float? {
        let rates = [Float?](arrayLiteral:
            self.imagesRating?.rate,
            self.complianceRating?.rate,
            self.dateQualityRating?.rate,
            self.dateRating?.rate,
            self.goozeRating?.rate
        ).flatMap{ $0 }

        guard rates.count > 0 else {
            return nil
        }

        let avg = rates.reduce(0, +) / Float(rates.count)

        return  avg
    }

    var comments: [Comment]?

    var topComment: String? {
        guard let comments = self.comments else {
            return nil
        }

        return comments.max{$0.count < $1.count}?.comment.localizedText()
    }

    var isActivated: Bool {
        if let activeUntil = self.activeUntil {
            return activeUntil.compare(Date()) != .orderedAscending
        } else {
            return false
        }
    }

    init(id: String, username: String, email: String) {
        self.id = id
        self.username = username
        self.email = email
        super.init()
        log.debug("\(self) init")
    }

    // MARK: - Gloss Deserialization

    required init?(json: JSON) {

        guard
            let id: String = "id" <~~ json,
            let username: String = "username" <~~ json,
            let email: String = "email" <~~ json
        else {
            log.error("Unable to instantiate GZEUser, missing required properties: \(json)")
            return nil
        }

        self.id = id
        self.username = username
        self.email = email
        // self.password = "password" <~~ json

        self.paypalCustomerId = "payment.paypalCustomerId" <~~ json
        self.payPalEmail = "payPalEmail" <~~ json

        self.birthday = Decoder.decode(dateForKey: "birthday", dateFormatter: GZEApi.dateFormatter)(json)
        self.gender = "gender" <~~ json
        self.searchForGender = "searchForGender" <~~ json

        if let weight: Double = "weight" <~~ json {
            self.weight = Float(weight)
        }
        if let height: Double = "height" <~~ json {
            self.height = Float(height)
        }
        self.origin = "origin" <~~ json
        self.phrase = "phrase" <~~ json

        self.languages = "languages" <~~ json
        self.interestedIn = "interestedIn" <~~ json

        self.currentLocation = "currentLocation" <~~ json
        self.currentLoc = "currentLoc" <~~ json
        self.dateLocation = "dateLocation" <~~ json
        self.activeUntil = Decoder.decode(dateForKey: "activeUntil", dateFormatter: GZEApi.dateFormatter)(json)

        self.registerCode = "registerCode" <~~ json
        self.invitedBy = "invitedBy" <~~ json

        self.mode = "mode" <~~ json
        self.status = "status" <~~ json
        self.loggedIn = "loggedIn" <~~ json
        self.createdAt = Decoder.decode(dateForKey: "createdAt", dateFormatter: GZEApi.dateFormatter)(json)
        self.updatedAt = Decoder.decode(dateForKey: "updatedAt", dateFormatter: GZEApi.dateFormatter)(json)

        self.photos = "photos" <~~ json
        self.profilePic = "profilePic" <~~ json
        self.searchPic = "searchPic" <~~ json

        self.activeDateRequest = "activeDateRequest" <~~ json

        self.imagesRating = "imagesRating" <~~ json
        self.complianceRating = "complianceRating" <~~ json
        self.dateQualityRating = "dateQualityRating" <~~ json
        self.dateRating = "dateRating" <~~ json
        self.goozeRating = "goozeRating" <~~ json

        self.comments = "comments" <~~ json

        super.init()
        
        log.debug("\(self) init")
    }

    // MARK: - Gloss Serialization

    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,

            "username" ~~> self.username,
            "email" ~~> self.email,
            //"password" ~~> self.password,

            "payment.paypalCustomerId" ~~> self.paypalCustomerId,
            "payPalEmail" ~~> self.payPalEmail,

            "gender" ~~> self.gender,
            "searchForGender"  ~~> self.searchForGender,
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
            "currentLoc" ~~> self.currentLoc,
            "dateLocation" ~~> self.dateLocation,
            Encoder.encode(dateForKey: "activeUntil", dateFormatter: GZEApi.dateFormatter)(self.activeUntil),

            "registerCode" ~~> self.registerCode,
            "invitedBy" ~~> self.invitedBy,

            "mode" ~~> self.mode,
            "status" ~~> self.status,
            "loggedIn" ~~> self.loggedIn,

            Encoder.encode(dateForKey: "birthday", dateFormatter: GZEApi.dateFormatter)(self.birthday),
            Encoder.encode(dateForKey: "createdAt", dateFormatter: GZEApi.dateFormatter)(self.createdAt),
            Encoder.encode(dateForKey: "updatedAt", dateFormatter: GZEApi.dateFormatter)(self.updatedAt),

            "imagesRating" ~~> self.imagesRating,
            "complianceRating" ~~> self.complianceRating,
            "dateQualityRating" ~~> self.dateQualityRating,
            "dateRating" ~~> self.dateRating,
            "goozeRating" ~~> self.goozeRating,

            "comments" ~~> self.comments,
        ])
    }

    func toChatUser() -> GZEChatUser {
        return GZEChatUser(
            id: id,
            username: username,
            searchPic: self.searchPic,
            profilePic: self.profilePic,
            imagesRating: self.imagesRating,
            complianceRating: self.complianceRating,
            dateQualityRating: self.dateQualityRating,
            dateRating: self.dateRating,
            goozeRating: self.goozeRating
        )
    }

    func setPhoto(fromFile file: GZEFile) {

        guard self.photos != nil else {
            log.error("photos array not set")
            return
        }

        guard let photoName = try? file.name.asURL().deletingPathExtension().relativeString else {
            log.error("Invalid photo name")
            return
        }

        log.debug("photoName: \(photoName)")

        guard
            let optionalPos = photoName.split(separator: "_").map({Int($0)}).last,
            let pos = optionalPos,
            pos >= 0 && pos < self.photos!.count
        else {
            log.error("Invalid index")
            return
        }

        self.photos![pos].name = file.name
        self.photos![pos].container = file.container
        self.photos![pos].url = "/containers/\(file.container)/download/\(file.name)"
        self.photos![pos].blocked = false

        self.photos![pos].removeFromCache()
    }

    // MARK: Validation

    enum Validation: String {

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
        case languages
        case interestedIn

        case registerCode
        case invitedBy

        case profilePic
        case searchPic
        case galleryPics
        case photos

        case imagesRating
        case complianceRating
        case dateQualityRating
        case dateRating
        case goozeRating

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

            case .language, .languages:
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
            case .galleryPics, .photos:
                key = "user.galleryPics.fieldName"

            case .imagesRating:
                key = "user.imagesRating.fieldName"
            case .complianceRating:
                key = "user.complianceRating.fieldName"
            case .dateQualityRating:
                key = "user.dateQualityRating.fieldName"
            case .dateRating:
                key = "user.dateRating.fieldName"
            case .goozeRating:
                key = "user.goozeRating.fieldName"
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
                ruleSet.add(rule: ValidationRuleLength(min: 4, error: GZEValidationError.lengthMin(fieldName: fieldName, min: 4)))

            case .birthday:
                //var date
                //ruleSet.add(rule: ValidationRuleComparison<Date>(min: Date(), max:Date(), error: GZEValidationError.underAge))
                break
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
            case .registerCode:
                ruleSet.add(rule: ValidationRuleLength(min: 1, error: GZEValidationError.required(fieldName: fieldName)))
                ruleSet.add(rule: ValidationRuleLength(max: 128, error: GZEValidationError.lengthMax(fieldName: fieldName, max: 128)))
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

// MARK: Hashable

extension GZEUser {
    override var hashValue: Int {
        return  self.id.hashValue
    }
}

// MARK: Equatable

func ==(lhs: GZEUser, rhs: GZEUser) -> Bool {
    return lhs.id == rhs.id
}

