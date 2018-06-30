//
//  GZEUserPaymentsRouter.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/29/18.
//  Copyright © 2018 Gooze. All rights reserved.
//
import Foundation
import Alamofire

enum GZEUserPaymentsRouter: URLRequestConvertible {

    case find(filter: Parameters)

    var route: String {
        return "UserTransactions"
    }

    var method: HTTPMethod {
        switch self {
        case .find:
            return .get
        }
    }

    var path: String {
        switch self {
        case .find:
            return "/"
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try GZEAppConfig.goozeApiUrl.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent("\(route)").appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        // Auth
        switch self {
        case .find:
            urlRequest.setValue(GZEAuthService.shared.token?.id, forHTTPHeaderField: "Authorization")
        }

        switch self {
        case .find(let filter):
            urlRequest = try LBURLEncoding.queryString.encode(urlRequest, with: filter)
        }

        return urlRequest
    }
}
