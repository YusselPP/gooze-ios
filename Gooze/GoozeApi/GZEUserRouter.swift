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
    case sendLocationUpdate(parameters: Parameters)
    case publicProfile(id: String)
    case addRate(id: String, parameters: Parameters)

    case signUp(parameters: Parameters)
    case login(parameters: Parameters, queryParams: Parameters)
    case facebookLogin(parameters: Parameters)
    case logout
    case reset(parameters: Parameters)
    case resetPassword(parameters: Parameters)

    case photo(url: String)

    case isValidRegisterCode(code: String)
    case unreadMessagesCount(id: String, parameters: Parameters)
    case sendEmail(parameters: Parameters)

    static let baseURLString = GZEAppConfig.goozeApiUrl
    static let route = "GoozeUsers"

    var method: HTTPMethod {
        switch self {
        case .createUser,
             .signUp,
             .login,
             .facebookLogin,
             .logout,
             .reset,
             .resetPassword,
             .sendLocationUpdate,
             .addRate,
             .sendEmail:
            return .post
        case .readUser,
             .count,
             .findByLocation,
             .publicProfile,
             .photo,
             .unreadMessagesCount,
             .isValidRegisterCode:
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
        case .sendLocationUpdate:
            return "\(GZEUserRouter.route)/sendLocationUpdate"
        case .publicProfile(let id):
            return "\(GZEUserRouter.route)/\(id)/publicProfile"
        case .addRate(let id, _):
            return "\(GZEUserRouter.route)/\(id)/addRate"

        case .signUp:
            return "\(GZEUserRouter.route)/signUp"
        case .login:
            return "\(GZEUserRouter.route)/login"
        case .facebookLogin:
            return "\(GZEUserRouter.route)/facebookLogin"
        case .logout:
            return "\(GZEUserRouter.route)/logout"
        case .reset:
            return "\(GZEUserRouter.route)/reset"
        case .resetPassword:
            return "\(GZEUserRouter.route)/resetPassword"

        case .photo(let url):
            return url

        case .isValidRegisterCode(let code):
            return "\(GZEUserRouter.route)/isValidRegisterCode/\(code)"
        case .unreadMessagesCount(let id, _):
            return "\(GZEUserRouter.route)/\(id)/unreadMessagesCount"
        case .sendEmail:
            return "\(GZEUserRouter.route)/sendEmail"
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try GZEUserRouter.baseURLString.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        switch self {
        case .readUser,
            .count,
            .findByLocation,
            .publicProfile:
            urlRequest.cachePolicy = .reloadIgnoringCacheData
        default: break
        }

        // Auth
        switch self {
        case .readUser,
             .updateUser,
             .logout,
             .findByLocation,
             .sendLocationUpdate,
             .publicProfile,
             .addRate,
             .photo,
             .unreadMessagesCount,
             .sendEmail:
            urlRequest.setValue(GZEApi.instance.accessToken?.id, forHTTPHeaderField: "Authorization")
        default:
            break
        }


        switch self {
        case .signUp(let parameters),
             .createUser(let parameters),
             .updateUser(_, let parameters),
             .reset(let parameters),
             .resetPassword(let parameters),
             .sendLocationUpdate(let parameters),
             .addRate(_, let parameters),
             .sendEmail(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)

        case .count(let parameters),
             .findByLocation(let parameters):
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: parameters)

        case .facebookLogin(let parameters),
             .unreadMessagesCount(_, let parameters):
            urlRequest = try LBURLEncoding.queryString.encode(urlRequest, with: parameters)

        case .login(let parameters, let queryParams):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: queryParams)

        default:
            break
        }

        return urlRequest
    }
}
