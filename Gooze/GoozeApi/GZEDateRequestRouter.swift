//
//  GZEDateRequestRouter.swift
//  Gooze
//
//  Created by Yussel on 3/29/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Alamofire

enum GZEDateRequestRouter: URLRequestConvertible {

    case find(parameters: Parameters)
    case update(id: String, parameters: Parameters)
    case updateAll(query: Parameters, data: Parameters)

    case findUnresponded(parameters: Parameters)

    case startDate(json: Parameters)
    case endDate(json: Parameters)
    case cancelDate(json: Parameters)
    case closeChat(parameters: Parameters)

    case createCharge(parameters: Parameters)

    static let baseURLString = GZEAppConfig.goozeApiUrl
    static let route = "DateRequests"

    var method: HTTPMethod {
        switch self {
        case .find,
             .findUnresponded:
            return .get
        case .updateAll,
             .startDate,
             .endDate,
             .cancelDate,
             .closeChat,
             .createCharge:
            return .post
        case .update:
            return .patch
        }
    }

    var path: String {
        switch self {
        case .find:
            return "\(GZEDateRequestRouter.route)/"
        case .update(let id, _):
            return "\(GZEDateRequestRouter.route)/\(id)"
        case .updateAll:
            return "\(GZEDateRequestRouter.route)/update"
        case .findUnresponded:
            return "\(GZEDateRequestRouter.route)/findUnresponded"
        case .startDate:
            return "\(GZEDateRequestRouter.route)/startDate"
        case .endDate:
            return "\(GZEDateRequestRouter.route)/endDate"
        case .cancelDate:
            return "\(GZEDateRequestRouter.route)/cancelDate"
        case .closeChat:
            return "\(GZEDateRequestRouter.route)/closeChat"
        case .createCharge:
            return "\(GZEDateRequestRouter.route)/createCharge"
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try GZEDateRequestRouter.baseURLString.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        switch self {
        case .find:
            urlRequest.cachePolicy = .reloadIgnoringCacheData
        default: break
        }

        // Auth
        switch self {
        case .find,
             .findUnresponded,
             .update,
             .updateAll,
             .startDate,
             .endDate,
             .cancelDate,
             .closeChat,
             .createCharge:
            urlRequest.setValue(GZEApi.instance.accessToken?.id, forHTTPHeaderField: "Authorization")
        }


        switch self {
        case .find(let parameters),
             .findUnresponded(let parameters):
            urlRequest = try LBURLEncoding.queryString.encode(urlRequest, with: parameters)
        case .startDate(let json),
             .endDate(let json),
             .cancelDate(let json):
            urlRequest = try JSONEncoding.default.encode(urlRequest, withJSONObject: json)
        case .update(_, let parameters),
             .closeChat(let parameters),
             .createCharge(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .updateAll(let query, let data):
            urlRequest = try LBURLEncoding.queryString.encode(urlRequest, with: query)
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: data)
        }

        return urlRequest
    }
}
