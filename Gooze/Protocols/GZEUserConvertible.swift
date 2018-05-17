//
//  GZEUserConvertible.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/4/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Gloss

class GZEUserConvertible: NSObject {
    
    static var subClassesConstructors: [GZEUserConvertible.Type.Type] = []
    
    static func arrayFrom(jsonArray: [JSON]) -> [GZEUserConvertible]? {
        var models: [GZEUserConvertible] = []

        for json in jsonArray {

            if let dateRequest = GZEDateRequest(json: json) {
                models.append(dateRequest)
            } else if let chatUser = GZEChatUser(json: json) {
                models.append(chatUser)
            } else {
                return nil
            }
        }

        return models
    }
    
    func getUser() -> GZEChatUser {
        fatalError("Must be overriden by subclas")
    }
}
