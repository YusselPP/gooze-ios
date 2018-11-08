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

    enum GoozeStatus: String {
        case paid
        case pending
        case review

        var localizedDescription: String {
            var str: String
            switch self {
            case .paid:
                str = "model.transaction.status.paid"
            case .pending:
                str = "model.transaction.status.pending"
            case .review:
                str = "model.transaction.status.review"
            }
            return str.localized()
        }
    }

    let from: String
    let to: String
    let amount: Decimal
    let netAmount: Decimal
    let paidAmount: Decimal?
    let status: String
    let goozeStatus: GoozeStatus
    let paymentMethodName: String
    let createdAt: Date

    required init?(json: JSON) {
        guard
            let from: String = "fromUser.username" <~~ json,
            let to: String = "toUser.username" <~~ json,
            let amountString: String = "amount" <~~ json,
            let amount = Decimal(string: amountString),
            let status: String = "status" <~~ json,
            let goozeStatus: GoozeStatus = "goozeStatus" <~~ json,
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
        self.goozeStatus = goozeStatus
        self.paymentMethodName = paymentMethodName
        self.createdAt = createdAt

        if
            let netAmountString: String = "netAmount" <~~ json,
            let netAmount = Decimal(string: netAmountString)
        {
            self.netAmount = netAmount
        } else {
            self.netAmount = 0
        }

        if
            let paidAmountString: String = "paidAmount" <~~ json,
            let paidAmount = Decimal(string: paidAmountString)
        {
            self.paidAmount = paidAmount
        } else {
            self.paidAmount = nil
        }
    }
}
