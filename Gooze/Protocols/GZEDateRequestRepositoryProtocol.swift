//
//  GZEDateRequestRepositoryProtocol.swift
//  Gooze
//
//  Created by Yussel on 3/29/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Gloss

protocol GZEDateRequestRepositoryProtocol {

    func findUnresponded() -> SignalProducer<[GZEDateRequest], GZEError>
    func findActiveDate(by: String) -> SignalProducer<[GZEDateRequest], GZEError>
    func startDate(_ dateRequest: GZEDateRequest) -> SignalProducer<GZEDateRequest, GZEError>
    func endDate(_ dateRequest: GZEDateRequest) -> SignalProducer<GZEDateRequest, GZEError>
}
