//
//  GZEDeviceTokenRouter.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/18/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Alamofire

enum GZEDeviceTokenRouter: URLRequestConvertible {

    case upsert(parameters: Parameters)

    var route: String {
        return "DeviceTokens"
    }

    var method: HTTPMethod {
        switch self {
        case .upsert:
            return .patch
        }
    }

    var path: String {
        switch self {
        case .upsert:
            return "/"
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try GZEAppConfig.goozeApiUrl.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent("\(route)" + path))
        urlRequest.httpMethod = method.rawValue

        // Auth
        switch self {
        case .upsert:
            urlRequest.setValue(GZEAuthService.shared.token?.id, forHTTPHeaderField: "Authorization")
        }

        switch self {
        case .upsert(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        }

        return urlRequest
    }
}
