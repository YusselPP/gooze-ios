//
//  GZEConektaErrorDetail.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/29/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

class GZEConektaErrorDetail {
    let code: GZEConektaError.Codes?
    let message: String?
    let param: String?

    init(
        code: GZEConektaError.Codes?,
        message: String?,
        param: String?
    ) {
        self.code = code
        self.message = message
        self.param = param
    }
}
