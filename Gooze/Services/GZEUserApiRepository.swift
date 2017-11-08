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
        case UserPassword = "email and password are required"
    }

    init() {
        log.debug("\(self) init")
    }

    // MARK: CRUD

    func create(_ user: GZEUser) -> SignalProducer<GZEUser, GZERepositoryError> {

        return SignalProducer<GZEUser, GZERepositoryError> { [weak self] sink, disposable in

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

            Alamofire.request(GZEUserRouter.createUser(parameters: userJSON))
                .responseJSON(completionHandler: this.createResponseHandler(sink: sink, createInstance: GZEUser.init))
        }
    }

    func update(_ user: GZEUser) -> SignalProducer<GZEUser, GZERepositoryError> {

        return SignalProducer<GZEUser, GZERepositoryError> { [weak self] sink, disposable in

            guard let this = self else {
                log.error("Unable to complete the task. Self has been disposed.")
                sink.send(error: .UnexpectedError)
                sink.sendInterrupted()
                return
            }

            disposable.add {
                log.debug("SignalProducer disposed")
            }

            log.debug("trying to create user")

            guard let userJSON = user.toJSON() else {
                log.error("Unable to serialize the user")
                sink.send(error: .UnexpectedError)
                sink.sendInterrupted()
                return
            }

            Alamofire.request(GZEUserRouter.createUser(parameters: userJSON))
                .responseJSON(completionHandler: this.createResponseHandler(sink: sink, createInstance: GZEUser.init))
        }
    }

    func delete(byId id: String) -> SignalProducer<Bool, GZERepositoryError> {

        return SignalProducer<Bool, GZERepositoryError> { [weak self] sink, disposable in

            guard let this = self else {
                log.error("Unable to complete the task. Self has been disposed.")
                sink.send(error: .UnexpectedError)
                sink.sendInterrupted()
                return
            }

            disposable.add {
                log.debug("find SignalProducer disposed")
            }

            guard !id.isEmpty else {
                sink.send(error: GZERepositoryError.BadRequest(message: "id parameter is required"))
                sink.sendInterrupted()
                return
            }

            let params = ["id": id]
            Alamofire.request(GZEUserRouter.login(parameters: params))
                .responseJSON(completionHandler: this.createResponseHandler(sink: sink, createInstance: { _ in
                    return true
                }))
        }
    }


    func find(byId id: String) -> SignalProducer<GZEUser, GZERepositoryError> {

        return SignalProducer<GZEUser, GZERepositoryError> { [weak self] sink, disposable in

            guard let this = self else {
                log.error("Unable to complete the task. Self has been disposed.")
                sink.send(error: .UnexpectedError)
                sink.sendInterrupted()
                return
            }

            disposable.add {
                log.debug("find SignalProducer disposed")
            }

            guard !id.isEmpty else {
                sink.send(error: GZERepositoryError.BadRequest(message: "id parameter is required"))
                sink.sendInterrupted()
                return
            }

            let params = ["id": id]
            Alamofire.request(GZEUserRouter.login(parameters: params))
                .responseJSON(completionHandler: this.createResponseHandler(sink: sink, createInstance: GZEUser.init))
        }
    }

    // MARK: Auth

    func login(_ email: String?, _ password: String?) -> SignalProducer<GZEAccesToken, GZERepositoryError> {

        return SignalProducer<GZEAccesToken, GZERepositoryError> { [weak self] sink, disposable in

            guard let this = self else {
                log.error("Unable to complete the task. Self has been disposed.")
                sink.send(error: .UnexpectedError)
                sink.sendInterrupted()
                return
            }

            disposable.add {
                log.debug("login SignalProducer disposed")
            }

            guard email != nil && !email!.isEmpty && password != nil && !password!.isEmpty else {
                sink.send(error: GZERepositoryError.BadRequest(message: ErrorMessage.UserPassword.rawValue))
                sink.sendCompleted()
                return
            }

            let params = ["email": email!, "password": password!]
            Alamofire.request(GZEUserRouter.login(parameters: params))
                .responseJSON(completionHandler: this.createResponseHandler(sink: sink, createInstance: { json in
                    let accessToken = GZEAccesToken(json: json)
                    if accessToken != nil {
                        GZEApi.instance.setToken(accessToken!)
                    }
                    return accessToken
                }))
        }
    }

    func signUp(_ user: GZEUser) -> SignalProducer<GZEFile, GZERepositoryError> {

        return create(user)
            .then(login(user.email, user.password))
            .then({ () -> (SignalProducer<GZEFile, GZERepositoryError>) in

                if let photos = user.photos {
                    return GZEStorageApiRepository().uploadFiles(photos.map {
                        if let image = $0.image {
                            return UIImagePNGRepresentation(image)
                        } else {
                            return nil
                        }
                    })
                } else {
                    return SignalProducer.empty
                }
            }())
    }

    // MARK: Response handler

    func createResponseHandler<T>(sink: Observer<T, GZERepositoryError>, createInstance: @escaping (JSON) -> T?) -> (DataResponse<Any>) -> Void {

        return { response in

            log.debug("Request: \(String(describing: response.request))")   // original url request
            log.debug("Request headers: \(String(describing: response.request?.allHTTPHeaderFields))")   // original url request
            log.debug("Response: \(String(describing: response.response))") // http url response

            switch response.result {
            case .success(let value):
                log.debug("Response value: \(value)")

                if let resultJSON = value as? JSON {
                    if
                        let errorJSON = resultJSON["error"] as? JSON,
                        let error = GZEApiError(json: errorJSON) {

                        log.error(error)
                        sink.send(error: .GZEApiError(error: error))
                        sink.sendCompleted()
                        return
                    } else if let resultInstance = createInstance(resultJSON) {
                        sink.send(value: resultInstance)
                    } else {
                        log.error("Unable to cast response object to: \(T.self)")
                        sink.send(error: .UnexpectedError)
                    }
                } else {
                    log.error("Unexpected response type. Expecting JSON")
                    sink.send(error: .UnexpectedError)
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
