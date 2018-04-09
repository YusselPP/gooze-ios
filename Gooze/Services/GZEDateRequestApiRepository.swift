//
//  GZEDateRequestApiRepository.swift
//  Gooze
//
//  Created by Yussel on 3/29/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Gloss
import Alamofire


class GZEDateRequestApiRepository: GZEDateRequestRepositoryProtocol {

    init() {
        log.debug("\(self) init")
    }


    func findUnresponded() -> SignalProducer<[GZEDateRequest], GZEError> {
        guard let userId = GZEApi.instance.accessToken?.userId else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer<[GZEDateRequest], GZEError> { sink, disposable in

            disposable.add {
                log.debug("findUnresponded SignalProducer disposed")
            }

            log.debug("trying to find user unresponded date requests")

            let params =
                [
                    "filter": [
                        "where": [
                            "or": [
                                ["status": GZEDateRequest.Status.sent.rawValue],
                                ["status": GZEDateRequest.Status.received.rawValue],
                                ["status": GZEDateRequest.Status.accepted.rawValue]
                            ],
                            "recipientId": userId
                        ],
                        "include": ["sender", "recipient"]
                    ]
                ] as [String : Any]
            Alamofire.request(GZEDateRequestRouter.find(parameters: params))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: { jsonArray in

                    return [GZEDateRequest].from(jsonArray: jsonArray)
                }))
        }
    }


    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
