//
//  GZEUserApiRepository.swift
//  Gooze
//
//  Created by Yussel on 10/23/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
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

                // self.api.setToken("agw4zsSKUk6BRB5uvoG6eQJFWTwzGxkTutqn00FSE4amoDyBUDit7FCKV3HvXFdB")

                let user = GZEUser(json: response?.toDictionary() as! JSON)
                sink.send(value: user!)

            }, failure: { error in

                log.error(error as Any)
                sink.send(error: GZERepositoryError.ModelNotFound)
            })

            sink.sendCompleted()
        }
    }

    func find(byId: String) -> SignalProducer<GZEUser, GZERepositoryError> {

        log.debug(self.api.adapter.accessToken)
        log.debug(UserDefaults.standard.object(forKey: "LBRESTAdapterAccessToken") as Any)

        return SignalProducer<GZEUser, GZERepositoryError> { sink, disposable in

            self.userRepository.find(byId: byId, success: { response in

                let user = GZEUser(json: response?.toDictionary() as! JSON)
                log.debug(response as Any)
                log.debug(user as Any)
                sink.send(value: user!)

            }, failure: { error in

                log.error(error as Any)
                sink.send(error: GZERepositoryError.ModelNotFound)
            })

            sink.sendCompleted()
        }
    }
}
