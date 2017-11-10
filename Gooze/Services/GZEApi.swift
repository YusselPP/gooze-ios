//
//  GZEApi.swift
//  Gooze
//
//  Created by Yussel on 10/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import Alamofire


class GZEApi {

    static var instance: GZEApi {
        if let api = _instance {
            return api
        }
        _instance = GZEApi()
        return _instance!
    }

    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter
    }

    var accessToken: GZEAccesToken?

    func loadToken() -> GZEAccesToken? {
        var token: GZEAccesToken? = nil
        if
            let jsonTokenString = UserDefaults.standard.string(forKey: GZEApi.tokenKey),
            let jsonData = jsonTokenString.data(using: .utf8),
            let storedToken = GZEAccesToken(data: jsonData) {

            token = storedToken
        }
        log.debug("Stored token obtained: \(String(describing: token))")
        return token
    }

    func setToken(_ accessToken: GZEAccesToken) {
        log.debug("Token set: \(accessToken)")
        self.accessToken = accessToken
        saveToken(accessToken)
    }

    func saveToken(_ accessToken: GZEAccesToken) {
        guard
            let jsonToken = accessToken.toJSON(),
            let jsonTokenData = try? JSONSerialization.data(withJSONObject: jsonToken),
            let jsonTokenString = String(data: jsonTokenData, encoding: .utf8) else {

            return
        }
        log.debug("Token stored: \(jsonTokenString)")
        UserDefaults.standard.set(jsonTokenString, forKey: GZEApi.tokenKey)
    }


    private static let tokenKey = "GZEAccessToken"
    private static var _instance: GZEApi?

    private init() {
        self.accessToken = loadToken()
    }

}
