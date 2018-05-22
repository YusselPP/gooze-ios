//
//  GZERateCommentsRouter.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/21/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Alamofire

enum GZERateCommentsRouter: URLRequestConvertible {

    case find(parameters: Parameters)

    static let baseURLString = GZEAppConfig.goozeApiUrl
    static let route = "GZERateComments"

    var method: HTTPMethod {
        switch self {
        case .find:
            return .get
        }
    }

    var path: String {
        switch self {
        case .find:
            return "\(GZERateCommentsRouter.route)/"
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
        }

        // Auth
        switch self {
        case .find:
            urlRequest.setValue(GZEApi.instance.accessToken?.id, forHTTPHeaderField: "Authorization")
        }

        switch self {
        case .find(let parameters):
            urlRequest = try LBURLEncoding.queryString.encode(urlRequest, with: parameters)
        }

        return urlRequest
    }
}
