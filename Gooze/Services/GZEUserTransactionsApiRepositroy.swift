//
//  GZEUserTransactionsApiRepositroy.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/29/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Alamofire
import Gloss

class GZEUserTransactionsApiRepositroy: GZEUserTransactionsRepositoryProtocol {

    func findMine() -> SignalProducer<[GZETransaction], GZEError> {
        guard let userId = GZEAuthService.shared.authUser?.id else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        let filter: JSON = [
            "filter": [
                "where": [
                    "or": [
                        ["fromUserId": userId],
                        ["toUserId": userId]
                    ]
                ],
                "include": [
                    "fromUser", "toUser"
                ]
            ]
        ]
        return find(filter: filter);
    }

    func find(filter: JSON) -> SignalProducer<[GZETransaction], GZEError> {
        return SignalProducer {sink, disposable in
            Alamofire.request(GZEUserPaymentsRouter.find(filter: filter))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: {
                    [GZETransaction].from(jsonArray: $0)
                }))
        }
    }
}
