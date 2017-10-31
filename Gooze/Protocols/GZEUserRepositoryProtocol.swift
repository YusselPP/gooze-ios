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

    func create(_ user: GZEUser) -> SignalProducer<Bool, GZERepositoryError>
    func login(_ username: String?, _ password: String?) -> SignalProducer<GZEUser, GZERepositoryError>
}
