//
//  GZEPayPalPaymentMethod.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/14/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Gloss

class GZEPayPalPaymentMethod: GZEPaymentMethod, Gloss.Decodable {

    required init?(json: JSON) {
        guard
            let name: String = "name" <~~ json,
            let token: String = "token" <~~ json,
            let imageUrl: String = "imageUrl" <~~ json
            else {
                log.error("unable to instantiate. invalid json")
                return nil
        }

        super.init(name: name, token: token, imageUrl: imageUrl)
    }
}
