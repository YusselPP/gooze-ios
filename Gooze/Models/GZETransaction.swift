//
//  GZETransaction.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/29/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Gloss

class GZETransaction: Gloss.Decodable {

    enum Status: String {
        case paid
        case confirmed = "settling"
        case failed
    }

    let from: String
    let to: String
    let amount: Decimal
    let status: String
    let paymentMethodName: String
    let createdAt: Date

    required init?(json: JSON) {
        guard
            let from: String = "fromUser.username" <~~ json,
            let to: String = "toUser.username" <~~ json,
            let amountString: String = "amount" <~~ json,
            let amount = Decimal(string: amountString),
            let status: String = "status" <~~ json,
            let paymentMethodName: String = "paymentMethod" <~~ json,
            let createdAt: Date = Decoder.decode(dateForKey: "createdAt", dateFormatter: GZEApi.dateFormatter)(json)
        else {
            log.error("unable to instantiate. invalid json")
            return nil
        }

        self.from = from
        self.to = to
        self.amount = amount
        self.status = status
        self.paymentMethodName = paymentMethodName
        self.createdAt = createdAt
    }
}
