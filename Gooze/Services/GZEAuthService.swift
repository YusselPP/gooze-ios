//
//  GZEAuthService.swift
//  Gooze
//
//  Created by Yussel on 3/20/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

class GZEAuthService: NSObject {
    static let shared = GZEAuthService()

    var token: GZEAccesToken? {
        return GZEApi.instance.accessToken
    }

    var authUser: GZEUser?

    var isAuthenticated: Bool {
        if let token = GZEApi.instance.accessToken {
            return !token.isExpired
        } else {
            return false
        }
    }

    func login(user: GZEUser) {
        self.authUser = user
        GZESocketManager.createDateSocket()
    }

    func logout() {
        GZESocketManager.destroyDateSocket()
    }
}
