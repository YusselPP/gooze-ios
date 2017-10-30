//
//  GZEUserApiRepository.swift
//  Gooze
//
//  Created by Yussel on 10/23/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import Localize_Swift
import ReactiveSwift
import Result
import Gloss
import LoopBack

class GZEUserApiRepository: LBPersistedModelRepository, GZEUserRepositoryProtocol {

    enum ErrorMessage: String {
        case UserPassword = "Username and password are required"
    }

    let modelName: String = "GoozeUsers"
    let api: GZEApi
    let userRepository: GZEUserRepository

    override init() {
        self.api = GZEApi.instance
        self.userRepository = api.adapter.repository(with: GZEUserRepository.self) as! GZEUserRepository
        super.init()
        log.debug("\(self) init")
    }


    func login(_ username: String?, _ password: String?) -> SignalProducer<GZEUser, GZERepositoryError> {


        return SignalProducer<GZEUser, GZERepositoryError> {[weak self] sink, disposable in

            guard let strongSelf = self else { return }
            disposable.add {
                log.debug("login SignalProducer disposed")
            }

            guard username != nil && !username!.isEmpty && password != nil && !password!.isEmpty else {
                sink.send(error: GZERepositoryError.BadRequest(message: ErrorMessage.UserPassword.rawValue))
                sink.sendCompleted()
                return
            }

            strongSelf.userRepository.login(email: username!, password: password!, success: { response in

                log.debug("login response: " + response.debugDescription)

                if
                    let tokenId = response?._id as? String,
                    let json = response?.toDictionary()["user"] as? JSON,
                    let user = GZEUser(json: json) {

                    strongSelf.api.setToken(tokenId)
                    sink.send(value: user)

                    log.debug("User logged in succesfully: " + user.description)
                } else {
                    sink.send(error: GZERepositoryError.InvalidResponseFormat)
                }

                sink.sendCompleted()

            }, failure: { error in

                log.debug("login failed: " + error.debugDescription)
                log.debug(GZERepositoryError.ModelNotFound.localizedDescription)

                sink.send(error: GZERepositoryError.ModelNotFound)
                sink.sendCompleted()
            })


        }
    }

    func find(byId id: String) -> SignalProducer<GZEUser, GZERepositoryError> {

        return SignalProducer<GZEUser, GZERepositoryError> { [weak self] sink, disposable in

            guard let strongSelf = self else { return }
            disposable.add {
                log.debug("find SignalProducer disposed")
            }
            
            strongSelf.userRepository.find(byId: id, success: { response in

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

    func create() -> SignalProducer<Bool, GZERepositoryError> {

        return SignalProducer<Bool, GZERepositoryError> { [weak self] sink, disposable in

            guard let strongSelf = self else { return }
            disposable.add {
                log.debug("save SignalProducer disposed")
            }

            log.debug("trying to save user")
            strongSelf.save(success: {

                log.debug("user saved!")
                sink.send(value: true)
                sink.sendCompleted()

            }, failure: { error in

                log.error("find failed: " + error.debugDescription)

                sink.send(error: GZERepositoryError.ModelNotFound)
                sink.sendCompleted()
            })
        }
    }

    func update() -> SignalProducer<Bool, GZERepositoryError> {

        return SignalProducer<Bool, GZERepositoryError> { [weak self] sink, disposable in

            guard let strongSelf = self else { return }
            disposable.add {
                log.debug("save SignalProducer disposed")
            }

            log.debug("trying to save user")
            strongSelf.save(success: {

                log.debug("user saved!")
                sink.send(value: true)
                sink.sendCompleted()

            }, failure: { error in

                log.error("find failed: " + error.debugDescription)

                sink.send(error: GZERepositoryError.ModelNotFound)
                sink.sendCompleted()
            })
        }
    }

    func delete() -> SignalProducer<Bool, GZERepositoryError> {

        return SignalProducer<Bool, GZERepositoryError> { [weak self] sink, disposable in

            guard let strongSelf = self else { return }
            disposable.add {
                log.debug("save SignalProducer disposed")
            }

            log.debug("trying to save user")
            strongSelf.save(success: {

                log.debug("user saved!")
                sink.send(value: true)
                sink.sendCompleted()

            }, failure: { error in

                log.error("find failed: " + error.debugDescription)

                sink.send(error: GZERepositoryError.ModelNotFound)
                sink.sendCompleted()
            })
        }
    }


    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
