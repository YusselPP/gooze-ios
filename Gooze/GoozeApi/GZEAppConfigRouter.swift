//
//  GZEAppConfigRouter.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 10/22/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Alamofire

enum GZEAppConfigRouter: URLRequestConvertible {

    case find(byName: String)

    var route: String {
        return "AppConfigs"
    }

    var method: HTTPMethod {
        switch self {
        case .find:
            return .get
        }
    }

    var path: String {
        switch self {
        case .find(let name):
            return "/findByName/\(name)"
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
        case .find:
            break
        }

        return urlRequest
    }
}
