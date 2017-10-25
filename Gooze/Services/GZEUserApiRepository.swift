//
//  GZEUserApiRepository.swift
//  Gooze
//
//  Created by Yussel on 10/23/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import Gloss
import LoopBack

class GZEUserApiRepository: LBPersistedModelRepository, GZEUserRepositoryProtocol {

    let modelName: String = "GoozeUsers"
    let api: GZEApi
    let userRepository: GZEUserRepository

    override init() {
        self.api = GZEApi()
        self.userRepository = api.adapter.repository(with: GZEUserRepository.self) as! GZEUserRepository
        super.init()
    }


    func login(_ username: String, _ password: String) -> SignalProducer<GZEUser, GZERepositoryError> {


        return SignalProducer<GZEUser, GZERepositoryError> { sink, disposable in

            self.userRepository.login(email: username, password: password, success: { response in

                log.debug("login response: " + response.debugDescription)

                if
                    let tokenId = response?._id as? String,
                    let json = response?.toDictionary()["user"] as? JSON,
                    let user = GZEUser(json: json) {

                    self.api.setToken(tokenId)
                    sink.send(value: user)
                } else {
                    sink.send(error: GZERepositoryError.InvalidResponseFormat)
                }

                sink.sendCompleted()

            }, failure: { error in

                log.error("login failed: " + error.debugDescription)

                sink.send(error: GZERepositoryError.ModelNotFound)
                sink.sendCompleted()
            })


        }
    }

    func find(byId id: String) -> SignalProducer<GZEUser, GZERepositoryError> {

        return SignalProducer<GZEUser, GZERepositoryError> { sink, disposable in

            self.userRepository.find(byId: id, success: { response in

                log.debug("find response: " + response.debugDescription)

                if
                    let jsonResponse = response?.toDictionary() as? JSON,
                    let user = GZEUser(json: jsonResponse) {

                    log.debug("found user instance: " + user.debugDescription)
                    sink.send(value: user)
                } else {
                    sink.send(error: GZERepositoryError.InvalidResponseFormat)
                }

                sink.sendCompleted()

            }, failure: { error in

                log.error("find failed: " + error.debugDescription)

                sink.send(error: GZERepositoryError.ModelNotFound)
                sink.sendCompleted()
            })


        }
    }
}
