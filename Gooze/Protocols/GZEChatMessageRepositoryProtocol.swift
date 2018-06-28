//
//  GZEChatMessageRepositoryProtocol.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/26/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Gloss

protocol GZEChatMessageRepositoryProtocol {
    func setRead(chatId: String) -> SignalProducer<Int, GZEError>

    func count(filter: JSON) -> SignalProducer<Int, GZEError>
    func update(filter: JSON, data: JSON) -> SignalProducer<Int, GZEError>
}
