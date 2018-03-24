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
    case count(parameters: Parameters)

    case findByLocation(parameters: Parameters)
    case publicProfile(id: String)

    case login(parameters: Parameters, queryParams: Parameters)
    case logout
    case reset(parameters: Parameters)
    case resetPassword(parameters: Parameters)

    case photo(url: String)

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
             .count,
             .findByLocation,
             .publicProfile,
             .photo:
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

        case .count:
            return "\(GZEUserRouter.route)/count"
        case .findByLocation:
            return "\(GZEUserRouter.route)/findByLocation"
        case .publicProfile(let id):
            return "\(GZEUserRouter.route)/\(id)/publicProfile"

        case .login:
            return "\(GZEUserRouter.route)/login"
        case .logout:
            return "\(GZEUserRouter.route)/logout"
        case .reset:
            return "\(GZEUserRouter.route)/reset"
        case .resetPassword:
            return "\(GZEUserRouter.route)/resetPassword"

        case .photo(let url):
            return url
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try GZEUserRouter.baseURLString.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue


        // Auth
        switch self {
        case .readUser,
             .updateUser,
             .logout,
             .findByLocation,
             .publicProfile,
             .photo:
            urlRequest.setValue(GZEApi.instance.accessToken?.id, forHTTPHeaderField: "Authorization")
        default:
            break
        }


        switch self {
        case .createUser(let parameters),
             .updateUser(_, let parameters),
             .reset(let parameters),
             .resetPassword(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)

        case .count(let parameters),
             .findByLocation(let parameters):
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)

        case .login(let parameters, let queryParams):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: queryParams)


        default:
            break
        }

        return urlRequest
    }
}
