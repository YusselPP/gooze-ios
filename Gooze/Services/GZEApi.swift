//
//  GZEApi.swift
//  Gooze
//
//  Created by Yussel on 10/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import Alamofire
import Gloss
import ReactiveSwift

class GZEApi {

    static var instance: GZEApi {
        if let api = _instance {
            return api
        }
        _instance = GZEApi()
        return _instance!
    }

    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter
    }

    var accessToken: GZEAccesToken?

    func loadToken() -> GZEAccesToken? {
        var token: GZEAccesToken? = nil
        if
            let jsonTokenString = UserDefaults.standard.string(forKey: GZEApi.tokenKey),
            let jsonData = jsonTokenString.data(using: .utf8),
            let storedToken = GZEAccesToken(data: jsonData) {

            token = storedToken
        }
        log.debug("Stored token obtained: \(String(describing: token))")
        return token
    }

    func setToken(_ accessToken: GZEAccesToken) {
        log.debug("Token set: \(accessToken)")
        self.accessToken = accessToken
        saveToken(accessToken)
    }

    func saveToken(_ accessToken: GZEAccesToken) {
        guard
            let jsonToken = accessToken.toJSON(),
            let jsonTokenData = try? JSONSerialization.data(withJSONObject: jsonToken),
            let jsonTokenString = String(data: jsonTokenData, encoding: .utf8) else {

            return
        }
        log.debug("Token stored: \(jsonTokenString)")
        UserDefaults.standard.set(jsonTokenString, forKey: GZEApi.tokenKey)
    }

    // MARK: Response handler

    static func createResponseHandler<T, U>(sink: Observer<T, GZEError>, createInstance: @escaping (U) -> T?) -> (DataResponse<Any>) -> Void {

        return { response in

            log.debug("Request: \(String(describing: response.request))")   // original url request
            log.debug("Request headers: \(String(describing: response.request?.allHTTPHeaderFields))")   // original url request
            log.debug("Response: \(String(describing: response.response))") // http url response

            switch response.result {
            case .success(let value):
                log.debug("Response value: \(value)")

                if
                    let resultJSON = value as? JSON,
                    let errorJSON = resultJSON["error"] as? JSON,
                    let error = GZEApiError(json: errorJSON)
                {
                    log.error(error)
                    sink.send(error: .repository(error: .GZEApiError(error: error)))
                    sink.sendCompleted()
                    return
                } else if let resultJSON = value as? U {
                    if let resultInstance = createInstance(resultJSON) {
                        sink.send(value: resultInstance)
                    } else {
                        log.error("Unable to cast response object to: \(T.self)")
                        sink.send(error: .repository(error: .UnexpectedError))
                    }
                } else {
                    log.error("Unexpected response type. Expecting \(U.self)")
                    sink.send(error: .repository(error: .UnexpectedError))
                }

                sink.sendCompleted()

            case .failure(let error):
                log.error(error)
                sink.send(error: .repository(error: .NetworkError(error: error)))
                sink.sendCompleted()
            }
        }
    }


    private static let tokenKey = "GZEAccessToken"
    private static var _instance: GZEApi?

    private init() {
        self.accessToken = loadToken()
    }

}
