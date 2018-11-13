//
//  GZEBalanceCellModel.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/28/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEBalanceCellModel: NSObject {
    let author: String
    let date: String
    let amount: String
    let amountColor: UIColor
    let status: String
    let onTap: CompletionBlock?

    init(
        author: String,
        date: String,
        amount: String,
        amountColor: UIColor,
        status: String,
        onTap: CompletionBlock? = nil
    ) {
        self.author = author
        self.date = date
        self.amount = amount
        self.amountColor = amountColor
        self.status = status
        self.onTap = onTap
    }
}
