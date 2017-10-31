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
import Alamofire

class GZEUserApiRepository: GZEUserRepositoryProtocol {

    enum ErrorMessage: String {
        case UserPassword = "Username and password are required"
    }

    init() {
        log.debug("\(self) init")
    }

    // MARK: CRUD

    func create(_ user: GZEUser) -> SignalProducer<Bool, GZERepositoryError> {

        return SignalProducer<Bool, GZERepositoryError> { [weak self] sink, disposable in

            guard let this = self else {
                log.error("Unable to complete the task. Self has been disposed.")
                sink.send(error: .UnexpectedError)
                sink.sendInterrupted()
                return
            }

            disposable.add {
                log.debug("create SignalProducer disposed")
            }

            log.debug("trying to create user")

            guard let userJSON = user.toJSON() else {
                log.error("Unable to serialize the user")
                sink.send(error: .UnexpectedError)
                sink.sendInterrupted()
                return
            }

            Alamofire.request(GZEUserRouter.createUser(parameters: userJSON)).responseJSON(completionHandler: this.createResponseHandler(sink: sink))

//            Alamofire.request(GZEUserRouter.createUser(parameters: userJSON)).responseJSON { response in
//
//                log.debug("Request: \(String(describing: response.request))")   // original url request
//                log.debug("Request headers: \(String(describing: response.request?.allHTTPHeaderFields))")   // original url request
//                log.debug("Response: \(String(describing: response.response))") // http url response
//
//                switch response.result {
//                case .success(let value):
//                    log.debug("Response value: \(value)")
//
//                    if let resultJSON = value as? JSON,
//                        let errorJSON = resultJSON["error"] as? JSON,
//                        let error = GZEApiError(json: errorJSON){
//
//                        log.error(error)
//                        sink.send(error: .GZEApiError(error: error))
//                        sink.sendCompleted()
//                        return
//                    }
//
//                    sink.send(value: true)
//                    sink.sendCompleted()
//
//                case .failure(let error):
//                    log.error(error)
//                    sink.send(error: .NetworkError(error: error))
//                    sink.sendCompleted()
//                }
//            }
        }
    }

//    func update() -> SignalProducer<Bool, GZERepositoryError> {
//
//        return SignalProducer<Bool, GZERepositoryError> { [weak self] sink, disposable in
//
//            guard let strongSelf = self else { return }
//            disposable.add {
//                log.debug("save SignalProducer disposed")
//            }
//
//            log.debug("trying to save user")
//            strongSelf.save(success: {
//
//                log.debug("user saved!")
//                sink.send(value: true)
//                sink.sendCompleted()
//
//            }, failure: { error in
//
//                log.error("find failed: " + error.debugDescription)
//
//                sink.send(error: GZERepositoryError.ModelNotFound)
//                sink.sendCompleted()
//            })
//        }
//    }
//
//    func delete() -> SignalProducer<Bool, GZERepositoryError> {
//
//        return SignalProducer<Bool, GZERepositoryError> { [weak self] sink, disposable in
//
//            guard let strongSelf = self else { return }
//            disposable.add {
//                log.debug("save SignalProducer disposed")
//            }
//
//            log.debug("trying to save user")
//            strongSelf.save(success: {
//
//                log.debug("user saved!")
//                sink.send(value: true)
//                sink.sendCompleted()
//
//            }, failure: { error in
//
//                log.error("find failed: " + error.debugDescription)
//
//                sink.send(error: GZERepositoryError.ModelNotFound)
//                sink.sendCompleted()
//            })
//        }
//    }


//    func find(byId id: String) -> SignalProducer<GZEUser, GZERepositoryError> {
//
//        return SignalProducer<GZEUser, GZERepositoryError> { [weak self] sink, disposable in
//
//            guard let strongSelf = self else { return }
//            disposable.add {
//                log.debug("find SignalProducer disposed")
//            }
//            
//            strongSelf.userRepository.find(byId: id, success: { response in
//
//                log.debug("find response: " + response.debugDescription)
//
//                if
//                    let jsonResponse = response?.toDictionary() as? JSON,
//                    let user = GZEUser(json: jsonResponse) {
//
//                    log.debug("found user instance: " + user.debugDescription)
//                    sink.send(value: user)
//                } else {
//                    sink.send(error: GZERepositoryError.InvalidResponseFormat)
//                }
//
//                sink.sendCompleted()
//
//            }, failure: { error in
//
//                log.error("find failed: " + error.debugDescription)
//
//                sink.send(error: GZERepositoryError.ModelNotFound)
//                sink.sendCompleted()
//            })
//
//
//        }
//    }

    // MARK: Auth

    func login(_ username: String?, _ password: String?) -> SignalProducer<GZEUser, GZERepositoryError> {

        return SignalProducer<GZEUser, GZERepositoryError> { [weak self] sink, disposable in

            guard let this = self else {
                log.error("Unable to complete the task. Self has been disposed.")
                sink.send(error: .UnexpectedError)
                sink.sendInterrupted()
                return
            }

            disposable.add {
                log.debug("login SignalProducer disposed")
            }

            guard username != nil && !username!.isEmpty && password != nil && !password!.isEmpty else {
                sink.send(error: GZERepositoryError.BadRequest(message: ErrorMessage.UserPassword.rawValue))
                sink.sendCompleted()
                return
            }

            let params = ["username": username!, "password": password!]
            Alamofire.request(GZEUserRouter.login(parameters: params)).responseJSON(completionHandler: this.createResponseHandler(sink: sink))
//            Alamofire.request(GZEUserRouter.login(parameters: params)).responseJSON { response in
//
//                log.debug("login response: " + response.debugDescription)
//
//                //                if let json = response.result.value {
//                log.debug("JSON: \(json)") // serialized json response
//
//                if let dictionary = json as? [String: Any],
//                    let err = dictionary["error"] as? [String: Any],
//                    let errMessage = err["message"] as? String {
//
//                    sink.send(value: GZEUser())
//                } else {
//                    sink.send(value: GZEUser())
//                }
//                sink.sendCompleted()
//            } else {
//                sink.send(error: GZERepositoryError.ModelNotFound)
//                sink.sendCompleted()
//            }
//            
//            sink.sendCompleted()
//            
        }
        //return SignalProducer.empty
    }

    func createResponseHandler<T>(sink: Observer<T, GZERepositoryError>) -> (DataResponse<Any>) -> Void {

        return { response in

            log.debug("Request: \(String(describing: response.request))")   // original url request
            log.debug("Request headers: \(String(describing: response.request?.allHTTPHeaderFields))")   // original url request
            log.debug("Response: \(String(describing: response.response))") // http url response

            switch response.result {
            case .success(let value):
                log.debug("Response value: \(value)")

                if let resultJSON = value as? JSON,
                    let errorJSON = resultJSON["error"] as? JSON,
                    let error = GZEApiError(json: errorJSON){

                    log.error(error)
                    sink.send(error: .GZEApiError(error: error))
                    sink.sendCompleted()
                    return
                }

                if let val = value as? T {
                    sink.send(value: val)
                }

                sink.sendCompleted()

            case .failure(let error):
                log.error(error)
                sink.send(error: .NetworkError(error: error))
                sink.sendCompleted()
            }
        }
    }


    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
