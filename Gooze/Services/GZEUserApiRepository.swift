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

    let storageRepository = GZEStorageApiRepository()

    init() {
        log.debug("\(self) init")
    }

    // MARK: CRUD

    func create(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError> {

        return SignalProducer<GZEUser, GZEError> { sink, disposable in

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
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: GZEUser.init))
        }
    }

    func update(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError> {

        return SignalProducer<GZEUser, GZEError> { sink, disposable in

            disposable.add {
                log.debug("update SignalProducer disposed")
            }

            log.debug("trying to update user")

            guard let userJSON = user.toJSON() else {
                log.error("Unable to serialize the user")
                sink.send(error: .repository(error: .UnexpectedError))
                sink.sendInterrupted()
                return
            }

            guard let userId = user.id else {
                log.error("The user instance must have an id in order to update it")
                sink.send(error: .repository(error: .UnexpectedError))
                sink.sendInterrupted()
                return
            }

            Alamofire.request(GZEUserRouter.updateUser(id: userId, parameters: userJSON))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: GZEUser.init))
        }
    }

    func delete(byId id: String) -> SignalProducer<Bool, GZEError> {

        return SignalProducer<Bool, GZEError> { sink, disposable in

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
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: { (json: JSON) in
                    return true
                }))
        }
    }


    func find(byId id: String) -> SignalProducer<GZEUser, GZEError> {

        return SignalProducer<GZEUser, GZEError> { sink, disposable in
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
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: GZEUser.init))
        }
    }

    func find(byLocation location: GZEUser.GeoPoint, maxDistance: Float, limit: Int = 5) -> SignalProducer<[GZEUser], GZEError> {
        return SignalProducer<[GZEUser], GZEError> { sink, disposable in

            disposable.add {
                log.debug("find byLocation SignalProducer disposed")
            }

            log.debug("trying to find users by location")

            guard let locationJSON = location.toJSON() else {
                log.error("Unable to serialize the location")
                sink.send(error: .repository(error: .UnexpectedError))
                sink.sendInterrupted()
                return
            }

            let params = ["location": locationJSON, "maxDistance": maxDistance, "limit": limit] as [String : Any]
            Alamofire.request(GZEUserRouter.findByLocation(parameters: params))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: { jsonArray in

                    return [GZEUser].from(jsonArray: jsonArray)
                }))
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
                    .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: { (json: JSON) in
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

    func signUp(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError> {
        var responseUser: GZEUser!

        return (
            create(user)
            .flatMap(FlattenStrategy.latest, transform: { aUser -> SignalProducer<GZEUser, GZEError> in
                responseUser = aUser

                return SignalProducer<GZEUser, GZEError> { sink, disposable in

                    sink.send(value: responseUser)
                    sink.sendCompleted()
                }
            })
            .then(login(user.email, user.password))
            .then({ () -> (SignalProducer<[GZEFile], GZEError>) in

                if let photos = user.photos, photos.count > 0 {
                    return storageRepository.uploadFiles(photos.enumerated().flatMap { (index, photo) in

                        var imageData: Data?

                        if let image = photo.image {

                            imageData = UIImageJPEGRepresentation(image, 1)

                            return GZEFile(name: photo.name ?? "pic-\(index).jpg", size: imageData?.count ?? 0, container: "picture", type: "image/jpeg", data: imageData)
                        } else {
                            return nil
                        }
                    }, container: "picture")
                } else {
                    return SignalProducer.init(value: [GZEFile]())
                }
            }())
            .flatMap(FlattenStrategy.latest, transform: { files -> SignalProducer<GZEUser, GZEError> in
                
                return SignalProducer<GZEUser, GZEError> { sink, disposable in

                    for (index, file) in files.enumerated() {
                        log.debug(file.toJSON() as Any)
                        log.debug(user.toJSON() as Any)

                        responseUser.photos![index].name = file.name
                        responseUser.photos![index].container = file.container
                        responseUser.photos![index].url = "/containers/\(file.container)/download/\(file.name)"
                        responseUser.photos![index].blocked = false
                    }

                    sink.send(value: responseUser)
                    sink.sendCompleted()
                }
            })
            .flatMap(FlattenStrategy.latest) { [weak self] (aUser) -> SignalProducer<GZEUser, GZEError> in

                guard let this = self else {
                    log.error("Unable to complete the task. Self has been disposed.")
                    return SignalProducer(error: GZEError.repository(error: .UnexpectedError))
                }

                let user = GZEUser()
                user.id = responseUser.id
                user.photos = aUser.photos

                return this.update(user)
            }
        )
    }

    private let emailRule = ValidationRuleLength(min: 1, error: GZEValidationError.required(fieldName: GZEUser.Validation.email.fieldName))
    private let passwordRule = ValidationRuleLength(min: 1, error: GZEValidationError.required(fieldName: GZEUser.Validation.password.fieldName))

    private func validateLogin(_ email: String?, _ password: String?) -> VValidationResult {
        let result = Validator.validate(input: email, rule: emailRule)
            .merge(with: Validator.validate(input: password, rule: passwordRule))

        log.debug(result)

        return result
    }


    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
