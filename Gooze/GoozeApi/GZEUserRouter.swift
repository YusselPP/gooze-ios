//
//  GZEUserRouter.swift
//  Gooze
//
//  Created by Yussel Paredes on 10/27/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import Alamofire

enum GZEUserRouter: URLRequestConvertible {
    case createUser(parameters: Parameters)
    case readUser(id: String)
    case updateUser(id: String, parameters: Parameters)
    case destroyUser(id: String)

    case findByLocation(parameters: Parameters)

    case login(parameters: Parameters)
    case logout
    case reset(parameters: Parameters)
    case resetPassword(parameters: Parameters)

    static let baseURLString = GZEAppConfig.goozeApiUrl
    static let route = "GoozeUsers"

    var method: HTTPMethod {
        switch self {
        case .createUser,
             .login,
             .logout,
             .reset,
             .resetPassword:
            return .post
        case .readUser,
             .findByLocation:
            return .get
        case .updateUser:
            return .patch
        case .destroyUser:
            return .delete
        }
    }

    var path: String {
        switch self {
        case .createUser:
            return GZEUserRouter.route
        case .readUser(let id),
             .updateUser(let id, _),
             .destroyUser(let id):
            return "\(GZEUserRouter.route)/\(id)"

        case .findByLocation:
            return "\(GZEUserRouter.route)/findByLocation"

        case .login:
            return "\(GZEUserRouter.route)/login"
        case .logout:
            return "\(GZEUserRouter.route)/logout"
        case .reset:
            return "\(GZEUserRouter.route)/reset"
        case .resetPassword:
            return "\(GZEUserRouter.route)/resetPassword"
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try GZEUserRouter.baseURLString.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue


        // Auth
        switch self {
        case .updateUser,
             .findByLocation:
            urlRequest.setValue(GZEApi.instance.accessToken?.id, forHTTPHeaderField: "Authorization")
        default:
            break
        }


        switch self {
        case .createUser(let parameters),
             .updateUser(_, let parameters),
             .login(let parameters),
             .reset(let parameters),
             .resetPassword(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)

        case .findByLocation(let parameters):
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)

        default:
            break
        }

        return urlRequest
    }
}
