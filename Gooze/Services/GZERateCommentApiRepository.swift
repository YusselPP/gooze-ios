//
//  GZERateCommentApiRepository.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/21/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Gloss
import Alamofire

class GZERateCommentApiRepository: GZERateCommentRepositoryProtocol {
    func findAll() -> SignalProducer<[GZERateComment], GZEError> {
        guard GZEApi.instance.accessToken != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer{ sink, disposable in

            disposable.add {
                log.debug("findAll SignalProducer disposed")
            }

            log.debug("trying to find comments")

            Alamofire.request(GZERateCommentsRouter.find(parameters: [:]))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: { jsonArray in
                    return [GZERateComment].from(jsonArray: jsonArray)
                }))
        }
    }
}
