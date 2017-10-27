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
import ReactiveSwift

class GZEUser: LBPersistedModel {

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

    var languages: [String] = []
    var interestedIn: [String] = []
    var photos: [String] = []

    var currentLocation: GeoPoint?
    var registerCode: String?
    var invitedBy: String?

    var mode: Mode?
    var status: Status?
    var loggedIn: Bool?
    var createdAt: Date?
    var updatedAt: Date?

    override init() {
        super.init()
        log.debug("\(self) init")
    }

    // MARK: - Gloss Deserialization
    init?(json: JSON) {
        super.init()
        log.debug("\(self) init")

        self.id = "id" <~~ json
        self.username = "username" <~~ json
        self.email = "email" <~~ json

        self.createdAt = Decoder.decode(dateForKey: "createdAt", dateFormatter: GZEUser.dateFormatter)(json)
        self.updatedAt = Decoder.decode(dateForKey: "updatedAt", dateFormatter: GZEUser.dateFormatter)(json)
    }

    init(repository: GZEUserRepositoryProtocol, parameters: [AnyHashable : Any]!) {
        super.init(repository: repository as! GZEUserApiRepository, parameters: parameters)
        log.debug("\(self) init")
    }

    func save() -> SignalProducer<Bool, GZERepositoryError> {

        return SignalProducer<Bool, GZERepositoryError> { [weak self] sink, disposable in

            guard let strongSelf = self else { return }
            disposable.add {
                log.debug("save SignalProducer disposed")
            }

            log.debug("trying to save user")
            strongSelf.save(success: {

                log.debug("user saved!")
                sink.send(value: true)
                sink.sendCompleted()

            }, failure: { error in

                log.error("find failed: " + error.debugDescription)

                sink.send(error: GZERepositoryError.ModelNotFound)
                sink.sendCompleted()
            })
        }
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
