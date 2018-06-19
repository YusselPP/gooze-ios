//
//  GZEDeviceTokenApiRepository.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/18/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Alamofire
import Gloss

class GZEDeviceTokenApiRepository: GZEDeviceTokenRepository {
    func upsert(token: String) -> SignalProducer<JSON, GZEError> {
        log.debug("upserting device token..")
        return SignalProducer {sink, disposable in

            disposable.add {
                log.debug("upsert signal disposed")
            }

            guard let vendorId = UIDevice.current.identifierForVendor?.uuidString else {
                log.error("vendorId parameter is required")
                sink.send(error: .repository(error: .UnexpectedError))
                return
            }
            guard let userId = GZEAuthService.shared.authUser?.id else {
                log.error("userId parameter is required")
                sink.send(error: .repository(error: .UnexpectedError))
                return
            }

            let parameters: JSON = [
                //"data": [
                    "token": token,
                    "vendorId": vendorId,
                    "userId": userId
                //]
            ]

            Alamofire.request(GZEDeviceTokenRouter.upsert(parameters: parameters))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: { $0
                }))
        }
    }
}
