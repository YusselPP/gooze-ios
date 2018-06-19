//
//  GZEDeviceTokenRepository.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/18/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Gloss

protocol GZEDeviceTokenRepository {
    func upsert(token: String) -> SignalProducer<JSON, GZEError>
}
