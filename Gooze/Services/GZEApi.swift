//
//  GZEApi.swift
//  Gooze
//
//  Created by Yussel on 10/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import LoopBack
import Alamofire

enum Router: URLRequestConvertible {
    case createUser(parameters: Parameters)
    case readUser(id: String)
    case updateUser(id: String, parameters: Parameters)
    case destroyUser(id: String)

    static let baseURLString = GZEAppConfig.goozeApiUrl
    static let usersPath = "/GoozeUsers"

    var method: HTTPMethod {
        switch self {
        case .createUser:
            return .post
        case .readUser:
            return .get
        case .updateUser:
            return .put
        case .destroyUser:
            return .delete
        }
    }

    var path: String {
        switch self {
        case .createUser:
            return Router.usersPath
        case .readUser(let id):
            return "\(Router.usersPath)/\(id)"
        case .updateUser(let id, _):
            return "\(Router.usersPath)/\(id)"
        case .destroyUser(let id):
            return "\(Router.usersPath)/\(id)"
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try Router.baseURLString.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        switch self {
        case .createUser(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .updateUser(_, let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        default:
            break
        }
        
        return urlRequest
    }
}

class GZEApi {

    static private var _instance: GZEApi?
    static var instance: GZEApi {
        if _instance == nil {
            _instance = GZEApi()
        }
        return _instance!
    }

    let tokenKey = "LBRESTAdapterAccessToken"
    let apiUrl = GZEAppConfig.goozeApiUrl
    let adapter: LBRESTAdapter

    private init() {
        adapter = LBRESTAdapter(url: URL(string: apiUrl)!)
        log.debug("\(self) init")
    }

    func setToken(_ accessToken: String) {
        log.debug("Token set: " + accessToken)
        adapter.accessToken = accessToken
        saveToken(accessToken)
    }

    func saveToken(_ accessToken: String) {
        UserDefaults.standard.set(accessToken, forKey: tokenKey)
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
