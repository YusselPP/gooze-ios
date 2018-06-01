//
//  GZEPaymentRepository.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/29/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol GZEPaymentRepository {

    func createToken(_ token: Token) -> SignalProducer<String, GZEError>
}
