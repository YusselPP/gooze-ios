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

    func create(username: String, email: String, password: String, userJSON: JSON?) -> SignalProducer<GZEUser, GZEError>
    func update(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError>
    func delete(byId id: String) -> SignalProducer<Bool, GZEError>
    func usernameExists(_ username: String) -> SignalProducer<Bool, GZEError>
    func emailExists(_ email: String) -> SignalProducer<Bool, GZEError>
    func facebookExist(_ facebookId: String) -> SignalProducer<Bool, GZEError>
    func find(byId id: String) -> SignalProducer<GZEUser, GZEError>
    func find(byLocation location: GZEUser.GeoPoint, maxDistance: Float, limit: Int) -> SignalProducer<[GZEUserConvertible], GZEError>
    func publicProfile(byId id: String) -> SignalProducer<GZEUser, GZEError>
    func login(_ username: String?, _ password: String?) -> SignalProducer<GZEAccesToken, GZEError>
    func facebookLogin(_ token: String) -> SignalProducer<GZEAccesToken, GZEError>
    func logout() -> SignalProducer<Void, GZEError>
    func signUp(username: String, email: String, password: String, userJSON: JSON?) -> SignalProducer<GZEUser, GZEError>
    func saveProfilePic(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError>
    func saveSearchPic(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError>
    func savePhotos(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError>
    func add(ratings: GZERatings, userId: String) -> SignalProducer<Bool, GZEError>

    func unreadMessagesCount(mode: GZEChatViewMode) -> SignalProducer<[String: Int], GZEError>
    func sendEmail(subject: String, text: String) -> SignalProducer<Void, GZEError>
}
