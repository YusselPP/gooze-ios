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
import Gloss
import Alamofire
import Validator

class GZEUserApiRepository: GZEUserRepositoryProtocol {

    init() {
        log.debug("\(self) init")
    }

    // MARK: CRUD

    func create(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError> {

        return SignalProducer<GZEUser, GZEError> { [weak self] sink, disposable in

            guard let this = self else {
                log.error("Unable to complete the task. Self has been disposed.")
                sink.send(error: .repository(error: .UnexpectedError))
                sink.sendInterrupted()
                return
            }

            disposable.add {
                log.debug("create SignalProducer disposed")
            }

            log.debug("trying to create user")

            guard let userJSON = user.toJSON() else {
                log.error("Unable to serialize the user")
                sink.send(error: .repository(error: .UnexpectedError))
                sink.sendInterrupted()
                return
            }

            Alamofire.request(GZEUserRouter.createUser(parameters: userJSON))
                .responseJSON(completionHandler: this.createResponseHandler(sink: sink, createInstance: GZEUser.init))
        }
    }

    func update(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError> {

        return SignalProducer<GZEUser, GZEError> { [weak self] sink, disposable in

            guard let this = self else {
                log.error("Unable to complete the task. Self has been disposed.")
                sink.send(error: .repository(error: .UnexpectedError))
                sink.sendInterrupted()
                return
            }

            disposable.add {
                log.debug("SignalProducer disposed")
            }

            log.debug("trying to create user")

            guard let userJSON = user.toJSON() else {
                log.error("Unable to serialize the user")
                sink.send(error: .repository(error: .UnexpectedError))
                sink.sendInterrupted()
                return
            }

            Alamofire.request(GZEUserRouter.createUser(parameters: userJSON))
                .responseJSON(completionHandler: this.createResponseHandler(sink: sink, createInstance: GZEUser.init))
        }
    }

    func delete(byId id: String) -> SignalProducer<Bool, GZEError> {

        return SignalProducer<Bool, GZEError> { [weak self] sink, disposable in

            guard let this = self else {
                log.error("Unable to complete the task. Self has been disposed.")
                sink.send(error: .repository(error: .UnexpectedError))
                sink.sendInterrupted()
                return
            }

            disposable.add {
                log.debug("find SignalProducer disposed")
            }

            guard !id.isEmpty else {
                sink.send(error: .repository(error: .BadRequest(message: "id parameter is required")))
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


    func find(byId id: String) -> SignalProducer<GZEUser, GZEError> {

        return SignalProducer<GZEUser, GZEError> { [weak self] sink, disposable in

            guard let this = self else {
                log.error("Unable to complete the task. Self has been disposed.")
                sink.send(error: .repository(error: .UnexpectedError))
                sink.sendInterrupted()
                return
            }

            disposable.add {
                log.debug("find SignalProducer disposed")
            }

            guard !id.isEmpty else {
                sink.send(error: .repository(error: .BadRequest(message: "id parameter is required")))
                sink.sendInterrupted()
                return
            }

            let params = ["id": id]
            Alamofire.request(GZEUserRouter.login(parameters: params))
                .responseJSON(completionHandler: this.createResponseHandler(sink: sink, createInstance: GZEUser.init))
        }
    }

    // MARK: Auth

    func login(_ email: String?, _ password: String?) -> SignalProducer<GZEAccesToken, GZEError> {

        return SignalProducer<GZEAccesToken, GZEError> { [weak self] sink, disposable in

            guard let this = self else {
                log.error("Unable to complete the task. Self has been disposed.")
                sink.send(error: .repository(error: .UnexpectedError))
                sink.sendInterrupted()
                return
            }

            disposable.add {
                log.debug("login SignalProducer disposed")
            }

            switch this.validateLogin(email, password) {
            case .valid:
                let params = ["email": email!, "password": password!]
                Alamofire.request(GZEUserRouter.login(parameters: params))
                    .responseJSON(completionHandler: this.createResponseHandler(sink: sink, createInstance: { json in
                        let accessToken = GZEAccesToken(json: json)
                        if accessToken != nil {
                            GZEApi.instance.setToken(accessToken!)
                        }
                        return accessToken
                    }))
            case .invalid(let failure):
                if let error = failure.first as? GZEValidationError {
                    sink.send(error: .validation(error: error))
                } else {
                    log.error("Unable to cast validation error to class: GZEValidationError")
                    sink.send(error: .repository(error: .UnexpectedError))
                }
                sink.sendCompleted()
            }
        }
    }

    func signUp(_ user: GZEUser) -> SignalProducer<GZEFile, GZEError> {

        return create(user)
            .then(login(user.email, user.password))
            .then({ () -> (SignalProducer<GZEFile, GZEError>) in

                if let photos = user.photos {
                    return GZEStorageApiRepository().uploadFiles(photos.map {
                        if let image = $0.image {
                            return UIImageJPEGRepresentation(image, 1)
                        } else {
                            return nil
                        }
                    })
                } else {
                    return SignalProducer.empty
                }
            }())
    }

    private let emailRule = ValidationRuleLength(min: 1, error: GZEValidationError.required(fieldName: GZEUser.Validation.email.fieldName))
    private let passwordRule = ValidationRuleLength(min: 1, error: GZEValidationError.required(fieldName: GZEUser.Validation.password.fieldName))

    private func validateLogin(_ email: String?, _ password: String?) -> VValidationResult {
        let result = Validator.validate(input: email, rule: emailRule)
            .merge(with: Validator.validate(input: password, rule: passwordRule))

        log.debug(result)

        return result
    }

    // MARK: Response handler

    func createResponseHandler<T>(sink: Observer<T, GZEError>, createInstance: @escaping (JSON) -> T?) -> (DataResponse<Any>) -> Void {

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
                        sink.send(error: .repository(error: .GZEApiError(error: error)))
                        sink.sendCompleted()
                        return
                    } else if let resultInstance = createInstance(resultJSON) {
                        sink.send(value: resultInstance)
                    } else {
                        log.error("Unable to cast response object to: \(T.self)")
                        sink.send(error: .repository(error: .UnexpectedError))
                    }
                } else {
                    log.error("Unexpected response type. Expecting JSON")
                    sink.send(error: .repository(error: .UnexpectedError))
                }

                sink.sendCompleted()

            case .failure(let error):
                log.error(error)
                sink.send(error: .repository(error: .NetworkError(error: error)))
                sink.sendCompleted()
            }
        }
    }


    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
