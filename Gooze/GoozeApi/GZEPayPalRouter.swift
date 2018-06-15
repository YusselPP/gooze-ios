//
//  GZEPayPalRouter.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/10/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Alamofire

enum GZEPayPalRouter: URLRequestConvertible {

    case clientToken
    case createCharge(parameters: Parameters)

    case findCustomer(id: String)
    case createCustomer(parameters: Parameters)

    case findPaymentMethods(customerId: String)
    case findPaymentMethod(token: String)
    case createPaymentMethod(parameters: Parameters)

    static let route = "Payments"

    var method: HTTPMethod {
        switch self {
        case .clientToken,
             .findCustomer,
             .findPaymentMethods,
             .findPaymentMethod:
            return .get
        case .createCharge,
             .createCustomer,
             .createPaymentMethod:
            return .post
        }
    }

    var path: String {
        switch self {
        case .clientToken:
            return "clientToken"
        case .createCharge:
            return "createCharge"

        case .findCustomer(let id):
            return "customer/\(id)"
        case .createCustomer:
            return "customer"

        case .findPaymentMethods(let customerId):
            return "customer/\(customerId)/paymentMethod"

        case .findPaymentMethod(let token):
            return "paymentMethod/\(token)"
        case .createPaymentMethod:
            return "paymentMethod"
        }
    }

    // MARK: URLRequestConvertible

    func asURLRequest() throws -> URLRequest {
        let url = try GZEAppConfig.goozeApiUrl.asURL()

        var urlRequest = URLRequest(url: url.appendingPathComponent("\(GZEPayPalRouter.route)/" + path))
        urlRequest.httpMethod = method.rawValue

        // Auth
        switch self {
        case .clientToken,
             .createCharge,
             .findCustomer,
             .createCustomer,
             .findPaymentMethods,
             .findPaymentMethod,
             .createPaymentMethod:
            urlRequest.setValue(GZEApi.instance.accessToken?.id, forHTTPHeaderField: "Authorization")
        }

        switch self {
        case .clientToken,
             .findCustomer,
             .findPaymentMethods,
             .findPaymentMethod:
            break
        case .createCharge(let parameters),
             .createCustomer(let parameters),
             .createPaymentMethod(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        }

        return urlRequest
    }
}
