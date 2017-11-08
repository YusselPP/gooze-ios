//
//  GZEUserRepositoryProtocol.swift
//  Gooze
//
//  Created by Yussel on 10/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol GZEUserRepositoryProtocol {

    func create(_ user: GZEUser) -> SignalProducer<GZEUser, GZERepositoryError>
    func update(_ user: GZEUser) -> SignalProducer<GZEUser, GZERepositoryError>
    func delete(byId id: String) -> SignalProducer<Bool, GZERepositoryError>
    func find(byId id: String) -> SignalProducer<GZEUser, GZERepositoryError>
    func login(_ username: String?, _ password: String?) -> SignalProducer<GZEAccesToken, GZERepositoryError>
    func signUp(_ user: GZEUser) -> SignalProducer<GZEFile, GZERepositoryError>
}
