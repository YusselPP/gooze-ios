//
//  GZEFacebookService.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/19/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import Gloss
import ReactiveSwift
import FBSDKLoginKit


class GZEFacebookService: NSObject {
    static let shared = GZEFacebookService()

    enum node: String {
        case me
    }

    func login(withReadPermissions permissions: [String], from vc: UIViewController) -> SignalProducer<FBSDKAccessToken, GZEError> {

        return SignalProducer {sink, disposable in

            FBSDKLoginManager()
                .logIn(withReadPermissions: permissions, from: vc) {
                    result, error in

                    if let error = error {
                        log.error(error)
                        sink.send(error: .facebookError(error: error))
                        return
                    }

                    guard let result = result else {
                        log.error("nil result and error")
                        sink.send(error: .repository(error: .UnexpectedError))
                        return
                    }

                    guard !result.isCancelled else {
                        log.debug("Cancelled")
                        sink.sendInterrupted()
                        return
                    }

                    log.debug("Logged in")
                    log.debug("facebook token: \(result.token)")

                    sink.send(value: result.token)
                    sink.sendCompleted()
                }
        }
    }

    func graphRequest(graphPath: String, parameters: JSON) -> SignalProducer<JSON, GZEError> {

        return SignalProducer{ sink, disposable in

            FBSDKGraphRequest(graphPath: graphPath, parameters: parameters)
                .start{conn, result, error in

                    if let error = error {
                        log.error(error)
                        sink.send(error: .facebookError(error: error))
                        return
                    }

                    guard let result = result else {
                        log.error("nil result and error")
                        sink.send(error: .repository(error: .UnexpectedError))
                        return
                    }

                    guard let resultJson = result as? JSON else {
                        log.error("Invalid format. Expecting JSON")
                        sink.send(error: .repository(error: .UnexpectedError))
                        return
                    }

                    sink.send(value: resultJson)
                    sink.sendCompleted()
                }
        }
    }
}
