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

    func findSentRequests(closed: Bool) -> SignalProducer<[GZEDateRequest], GZEError>
    func findReceivedRequests(closed: Bool) -> SignalProducer<[GZEDateRequest], GZEError>
    func findUnresponded() -> SignalProducer<[GZEDateRequest], GZEError>
    func findActiveDate(by: String) -> SignalProducer<[GZEDateRequest], GZEError>
    func startDate(_ dateRequest: GZEDateRequest) -> SignalProducer<(GZEDateRequest, GZEUser), GZEError>
    func endDate(_ dateRequest: GZEDateRequest) -> SignalProducer<(GZEDateRequest, GZEUser), GZEError>
    func cancelDate(_ dateRequest: GZEDateRequest) -> SignalProducer<(GZEDateRequest, GZEUser), GZEError>
    func close(_ dateRequest: GZEDateRequest, mode: GZEChatViewMode) -> SignalProducer<GZEDateRequest, GZEError>
    func createCharge(
        dateRequest: GZEDateRequest,
        amount: Decimal,
        clientTaxAmount: Decimal,
        goozeTaxAmount: Decimal,
        paymentMethodToken: String,
        senderId: String,
        username: String,
        chat: GZEChat,
        mode: GZEChatViewMode
    ) -> SignalProducer<(GZEDateRequest, GZEUser), GZEError>
}
