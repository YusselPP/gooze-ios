//
//  GZEChatMessageRouter.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/26/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Alamofire

enum GZEChatMessageRouter: URLRequestConvertible {

    case count(filter: Parameters)
    case update(filter: Parameters, data: Parameters)

    var route: String {
        return "ChatMessages"
    }

    var method: HTTPMethod {
        switch self {
        case .count:
            return .get
        case .update:
            return .post
        }
    }

    var path: String {
        switch self {
        case .count:
            return "/count"
        case .update:
            return "/update"
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try GZEAppConfig.goozeApiUrl.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent("\(route)").appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        // Auth
        switch self {
        case .count,
             .update:
            urlRequest.setValue(GZEAuthService.shared.token?.id, forHTTPHeaderField: "Authorization")
        }

        switch self {
        case .count(let filter):
            urlRequest = try LBURLEncoding.queryString.encode(urlRequest, with: filter)
        case .update(let filter, let data):
            urlRequest = try LBURLEncoding.queryString.encode(urlRequest, with: filter)
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: data)
        }

        return urlRequest
    }
}
