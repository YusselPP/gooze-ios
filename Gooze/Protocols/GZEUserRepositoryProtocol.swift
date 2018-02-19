//
//  GZEUserRepositoryProtocol.swift
//  Gooze
//
//  Created by Yussel on 10/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Gloss

protocol GZEUserRepositoryProtocol {

    func create(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError>
    func update(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError>
    func delete(byId id: String) -> SignalProducer<Bool, GZEError>
    func find(byId id: String) -> SignalProducer<GZEUser, GZEError>
    func find(byLocation location: GZEUser.GeoPoint, maxDistance: Float, limit: Int) -> SignalProducer<[GZEUser], GZEError>
    func login(_ username: String?, _ password: String?) -> SignalProducer<GZEAccesToken, GZEError>
    func signUp(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError>
    func saveProfilePic(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError>
    func saveSearchPic(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError>
    func savePhotos(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError>
}
