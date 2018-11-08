//
//  GZEUserTransactionsRepositoryProtocol.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/29/18.
//  Copyright © 2018 Gooze. All rights reserved.
//
import Foundation
import ReactiveSwift
import Gloss

protocol GZEUserTransactionsRepositoryProtocol {
    func findMine() -> SignalProducer<[GZETransaction], GZEError>
    func findGooze() -> SignalProducer<[GZETransaction], GZEError>
    func findClient() -> SignalProducer<[GZETransaction], GZEError>
    func find(filter: JSON) -> SignalProducer<[GZETransaction], GZEError>
}
