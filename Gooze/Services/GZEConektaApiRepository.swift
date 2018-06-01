//
//  GZEConektaApiRepository.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/29/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift

class GZEConektaApiRepository: GZEPaymentRepository {

    func createToken(_ token: Token) -> SignalProducer<String, GZEError> {
        guard GZEAuthService.shared.isAuthenticated else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer { sink, disposable in

            disposable.add {
                log.debug("createToken SignalProducer disposed")
            }

            log.debug("trying to createToken")

            token.create(success: { (data) -> Void in
                log.debug(data?.debugDescription as Any)

                if let data = data as? Dictionary<String, Any> {
                    let objectType = data["object"] as? String

                    if objectType == "error", let error = GZEConektaTokenError(json: data) {
                        sink.send(error: .conektaToken(error: error))
                        return
                    } else if objectType == "token", let token = data["id"] as? String {
                        sink.send(value: token)
                        sink.sendCompleted()
                        return
                    } else {
                        log.error("Unexpected response type. Expecting Token.String or \(GZEConektaError.self)")
                    }
                } else {
                    log.error("Received nil data")
                }

                sink.send(error: .repository(error: .UnexpectedError))

            }, andError: { (error) -> Void in
                log.debug(error?.localizedDescription as Any)
                if let error = error {
                    sink.send(error: .repository(error: .NetworkError(error: error)))
                } else {
                    sink.send(error: .repository(error: .UnexpectedError))
                }
            })
        }
    }
}
