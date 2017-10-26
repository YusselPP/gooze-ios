//
//  GZEApi.swift
//  Gooze
//
//  Created by Yussel on 10/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import Gloss
import LoopBack

class GZEApi {

    static private var _instance: GZEApi?
    static var instance: GZEApi {
        if _instance == nil {
            _instance = GZEApi()
        }
        return _instance!
    }

    let tokenKey = "LBRESTAdapterAccessToken"
    let apiUrl = "http://localhost:3000/api"
    let adapter: LBRESTAdapter

    private init() {
        adapter = LBRESTAdapter(url: URL(string: apiUrl)!)
    }

    func setToken(_ accessToken: String) {
        log.debug("Token set: " + accessToken)
        adapter.accessToken = accessToken
        saveToken(accessToken)
    }

    func saveToken(_ accessToken: String) {
        UserDefaults.standard.set(accessToken, forKey: tokenKey)
    }
}
