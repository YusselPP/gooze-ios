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

    static let baseURLString = GZEAppConfig.goozeApiUrl
    static let route = "DateRequests"

    var method: HTTPMethod {
        switch self {
        case .find:
            return .get
        }
    }

    var path: String {
        switch self {
        case .find:
            return "\(GZEDateRequestRouter.route)/"
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try GZEDateRequestRouter.baseURLString.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue


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
