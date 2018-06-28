//
//  GZEChatMessageApiRepository.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/26/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Alamofire
import Gloss

class GZEChatMessageApiRepository: GZEChatMessageRepositoryProtocol {

    func setRead(chatId: String) -> SignalProducer<Int, GZEError> {
        guard let userId = GZEAuthService.shared.authUser?.id else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        let filter: JSON = [
            "where": [
                "chatId": chatId,
                "senderId": ["neq": userId],
                "status": ["neq": GZEChatMessage.Status.read.rawValue]
            ]
        ]

        let data: JSON = [
            "status": GZEChatMessage.Status.read.rawValue
        ]

        return update(filter: filter, data: data)
    }


    func count(filter: JSON) -> SignalProducer<Int, GZEError> {
        return SignalProducer {sink, disposable in
            Alamofire.request(GZEChatMessageRouter.count(filter: filter))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: {
                    (json: JSON) in
                    return json["count"] as? Int
                }))
        }
    }

    func update(filter: JSON, data: JSON) -> SignalProducer<Int, GZEError> {
        return SignalProducer {sink, disposable in
            Alamofire.request(GZEChatMessageRouter.update(filter: filter, data: data))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: {
                    (json: JSON) in
                    return json["count"] as? Int
                }))
        }
    }
}
