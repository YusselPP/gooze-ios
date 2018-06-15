//
//  GZEPaymentMethod.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/14/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

class GZEPaymentMethod: NSObject {

    let name: String
    let token: String
    let imageUrl: String

    var imageUrlRequest: URLRequest {
        return URLRequest(url: URL(string: imageUrl)!)
    }

    init(name: String, token: String, imageUrl: String) {
        self.name = name
        self.token = token
        self.imageUrl = imageUrl
    }
}
