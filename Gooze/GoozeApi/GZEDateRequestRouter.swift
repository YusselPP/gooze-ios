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

    case startDate(json: Parameters)
    case endDate(json: Parameters)

    static let baseURLString = GZEAppConfig.goozeApiUrl
    static let route = "DateRequests"

    var method: HTTPMethod {
        switch self {
        case .find:
            return .get
        case .startDate,
             .endDate:
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
        case .startDate:
            return "\(GZEDateRequestRouter.route)/startDate"
        case .endDate:
            return "\(GZEDateRequestRouter.route)/endDate"
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
             .update,
             .startDate,
             .endDate:
            urlRequest.setValue(GZEApi.instance.accessToken?.id, forHTTPHeaderField: "Authorization")
        }


        switch self {
        case .find(let parameters):
            urlRequest = try LBURLEncoding.queryString.encode(urlRequest, with: parameters)
        case .startDate(let json),
             .endDate(let json):
            urlRequest = try JSONEncoding.default.encode(urlRequest, withJSONObject: json)
        case .update(_, let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        }

        return urlRequest
    }
}
