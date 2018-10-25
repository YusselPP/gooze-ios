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
import AlamofireImage
import Validator

class GZEUserApiRepository: GZEUserRepositoryProtocol {

    let storageRepository = GZEStorageApiRepository()

    init() {
        log.debug("\(self) init")
    }

    // MARK: CRUD

    func create(username: String, email: String, password: String, userJSON: JSON? = nil) -> SignalProducer<GZEUser, GZEError> {

        return SignalProducer<GZEUser, GZEError> { sink, disposable in

            disposable.add {
                log.debug("create SignalProducer disposed")
            }

            log.debug("trying to create user")

            var unwrappedUserJSON: JSON
            if userJSON == nil {
                unwrappedUserJSON = JSON()
            } else {
                unwrappedUserJSON = userJSON!
            }

            unwrappedUserJSON["username"] = username
            unwrappedUserJSON["email"] = email
            unwrappedUserJSON["password"] = password

            Alamofire.request(GZEUserRouter.createUser(parameters: unwrappedUserJSON))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: GZEUser.init))
        }
    }

    func update(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError> {

        guard GZEApi.instance.accessToken != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

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

            let userId = user.id

            Alamofire.request(GZEUserRouter.updateUser(id: userId, parameters: userJSON))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: GZEUser.init))
        }
    }

    func delete(byId id: String) -> SignalProducer<Bool, GZEError> {

        guard GZEApi.instance.accessToken != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer<Bool, GZEError> { sink, disposable in

            disposable.add {
                log.debug("delete SignalProducer disposed")
            }

            guard !id.isEmpty else {
                sink.send(error: .validation(error: .required(fieldName: "id")))
                sink.sendInterrupted()
                return
            }

            Alamofire.request(GZEUserRouter.destroyUser(id: id))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: { (json: JSON) in
                    return true
                }))
        }
    }

    func count(_ params: JSON) -> SignalProducer<Int, GZEError> {

        return SignalProducer<Int, GZEError> { sink, disposable in

            disposable.add {
                log.debug("count SignalProducer disposed")
            }

            log.debug("counting users")

            Alamofire.request(GZEUserRouter.count(parameters: params))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink) { (countResult: JSON) in

                    guard let count = countResult["count"] as? Int else {
                        log.error("Unable to cast 'count' property to \(Int.self)")
                        sink.send(error: .repository(error: .UnexpectedError))
                        sink.sendInterrupted()
                        return 0
                    }

                    return count
                })
        }
    }

    func isValidRegisterCode(_ code: String) -> SignalProducer<Bool, GZEError> {
        return SignalProducer{ sink, disposable in

            disposable.add {
                log.debug("isValidRegisterCode SignalProducer disposed")
            }

            log.debug("Validating register code...")

            Alamofire.request(GZEUserRouter.isValidRegisterCode(code: code))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink) { (result: JSON) in

                    guard let isValid = result["isValid"] as? Bool else {
                        log.error("Unable to cast 'count' property to \(Bool.self)")
                        sink.send(error: .repository(error: .UnexpectedError))
                        return false
                    }

                    return isValid
                })
        }
    }

    func usernameExists(_ username: String) -> SignalProducer<Bool, GZEError> {

        log.debug("requesting usernameExists")

        guard !username.isEmpty else {
            return SignalProducer(value: false)
        }

        let params = [
            "where": ["username": username]
        ] as [String : Any]

        return self.count(params).map { $0 > 0 }
    }

    func emailExists(_ email: String) -> SignalProducer<Bool, GZEError> {

        log.debug("requesting emailExists")

        guard !email.isEmpty else {
            return SignalProducer(value: false)
        }

        let params = [
            "where": ["email": email]
        ] as [String : Any]

        return self.count(params).map { $0 > 0 }
    }

    func facebookExist(_ facebookId: String) -> SignalProducer<Bool, GZEError> {

        log.debug("requesting facebookExist")

        guard !facebookId.isEmpty else {
            return SignalProducer(value: false)
        }

        let params = [
            "where": ["facebookId": facebookId]
            ] as [String : Any]

        return self.count(params).map { $0 > 0 }
    }


    func find(byId id: String) -> SignalProducer<GZEUser, GZEError> {

        guard GZEApi.instance.accessToken != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer<GZEUser, GZEError> { sink, disposable in
            disposable.add {
                log.debug("find SignalProducer disposed")
            }

            guard !id.isEmpty else {
                sink.send(error: .validation(error: .required(fieldName: "id")))
                sink.sendInterrupted()
                return
            }

            Alamofire.request(GZEUserRouter.readUser(id: id))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: GZEUser.init))
        }
    }

    func find(byLocation location: GZEUser.GeoPoint, maxDistance: Float, limit: Int = 5) -> SignalProducer<[GZEUserConvertible], GZEError> {
        guard GZEApi.instance.accessToken != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer<[GZEUserConvertible], GZEError> { sink, disposable in

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
                    return GZEUserConvertible.arrayFrom(jsonArray: jsonArray)
                }))
        }
    }

    func publicProfile(byId id: String) -> SignalProducer<GZEUser, GZEError> {
        guard GZEApi.instance.accessToken != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer<GZEUser, GZEError> { sink, disposable in
            disposable.add {
                log.debug("public profile SignalProducer disposed")
            }

            guard !id.isEmpty else {
                sink.send(error: .validation(error: .required(fieldName: "id")))
                sink.sendInterrupted()
                return
            }

            Alamofire.request(GZEUserRouter.publicProfile(id: id))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: GZEUser.init))
        }
    }

    func add(ratings: GZERatings, userId: String) -> SignalProducer<Bool, GZEError> {
        guard GZEApi.instance.accessToken != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        guard !userId.isEmpty else {
            log.error("userId is requiered, found empty string")
            return SignalProducer(error: .repository(error: .UnexpectedError))
        }

        guard let ratingsJson = ratings.toJSON() else {
            log.error("unable to parse ratings to json")
            return SignalProducer(error: .repository(error: .UnexpectedError))
        }

        return SignalProducer { sink, disposable in
            disposable.add {
                log.debug("add ratings SignalProducer disposed")
            }

            Alamofire.request(GZEUserRouter.addRate(id: userId, parameters: ratingsJson))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: {
                    Bool($0 as NSNumber)
                }))
        }
    }

    func unreadMessagesCount(mode: GZEChatViewMode) -> SignalProducer<[String: Int], GZEError> {
        guard let userId = GZEAuthService.shared.authUser?.id else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer{sink, disposable in

            Alamofire.request(GZEUserRouter.unreadMessagesCount(id: userId, parameters: ["mode": mode.rawValue]))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: {
                    (json: JSON) in
                    json as? [String: Int]
                }))
        }
    }

    func sendEmail(subject: String, text: String) -> SignalProducer<Void, GZEError> {
        guard GZEAuthService.shared.authUser != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer{sink, disposable in

            Alamofire.request(GZEUserRouter.sendEmail(parameters: ["mail": ["subject": subject, "text": text]]))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: {()}))
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
                Alamofire.request(GZEUserRouter.login(parameters: params, queryParams: ["include": "user"]))
                    .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: this.handleLoginResponse))
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

    func facebookLogin(_ token: String) -> SignalProducer<GZEAccesToken, GZEError> {

        return SignalProducer {[weak self] sink, disposable in

            disposable.add {
                log.debug("login SignalProducer disposed")
            }

            guard let this = self else {
                log.error("Unable to complete the task. Self has been disposed.")
                sink.send(error: .repository(error: .UnexpectedError))
                return
            }

            let params: JSON = ["token": token]

            Alamofire.request(GZEUserRouter.facebookLogin(parameters: params))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: this.handleLoginResponse))
        }
    }

    func logout() -> SignalProducer<Void, GZEError> {
        guard GZEApi.instance.accessToken != nil else {
            return SignalProducer(error: .repository(error: .AuthRequired))
        }

        return SignalProducer<Void, GZEError> {sink, disposable in

            return Alamofire.request(GZEUserRouter.logout).response{data in
                sink.sendCompleted()
            }
        }
    }

    func saveProfilePic(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError> {

        if let photo = user.profilePic {
            return (
                storageRepository.uploadFiles([photo].enumerated().flatMap { (index, photo) in

                    var imageData: Data?

                    if let image = photo.image {

                        imageData = UIImageJPEGRepresentation(image, 1)

                        return GZEFile(name: photo.name ?? "pic-\(index).jpg", size: imageData?.count ?? 0, container: GZEUser.Photo.container, type: "image/jpeg", data: imageData)
                    } else {
                        return nil
                    }
                }, container: GZEUser.Photo.container)
                    .flatMap(FlattenStrategy.latest) { files -> SignalProducer<GZEUser, GZEError> in

                        return SignalProducer<GZEUser, GZEError> { sink, disposable in
                            for file in files {
                                log.debug(file.toJSON() as Any)

                                user.profilePic!.name = file.name
                                user.profilePic!.container = file.container
                                user.profilePic!.url = "/containers/\(file.container)/download/\(file.name)"
                                user.profilePic!.blocked = false

                                user.profilePic!.removeFromCache(withIdentifier: NoirFilter().identifier)

                                log.debug(user.toJSON() as Any)
                            }

                            sink.send(value: user)
                            sink.sendCompleted()
                        }
                    }
                    .flatMap(FlattenStrategy.latest) { [weak self] (aUser) -> SignalProducer<GZEUser, GZEError> in

                        guard let this = self else {
                            log.error("Unable to complete the task. Self has been disposed.")
                            return SignalProducer(error: .repository(error: .UnexpectedError))
                        }

                        let user = GZEUser(id: aUser.id, username: aUser.username, email: aUser.email)
                        user.profilePic = aUser.profilePic

                        return this.update(user)
                    }
            )
        } else {
            return SignalProducer(error: .validation(error: .required(fieldName: GZEUser.Validation.profilePic.fieldName)))
        }

    }

    func saveSearchPic(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError> {

        if let photo = user.searchPic {
            return storageRepository.uploadFiles([photo].enumerated().flatMap { (index, photo) in

                var imageData: Data?

                if let image = photo.image {

                    imageData = UIImageJPEGRepresentation(image, 1)

                    return GZEFile(name: photo.name ?? "pic-\(index).jpg", size: imageData?.count ?? 0, container: GZEUser.Photo.container, type: "image/jpeg", data: imageData)
                } else {
                    return nil
                }
            }, container: GZEUser.Photo.container)
                .flatMap(FlattenStrategy.latest, transform: { files -> SignalProducer<GZEUser, GZEError> in

                    return SignalProducer<GZEUser, GZEError> { sink, disposable in

                        for file in files {
                            log.debug(file.toJSON() as Any)

                            user.searchPic!.name = file.name
                            user.searchPic!.container = file.container
                            user.searchPic!.url = "/containers/\(file.container)/download/\(file.name)"
                            user.searchPic!.blocked = false

                            user.searchPic!.removeFromCache(withIdentifier: NoirFilter().identifier)

                            log.debug(user.toJSON() as Any)
                        }

                        sink.send(value: user)
                        sink.sendCompleted()
                    }
                })
                .flatMap(FlattenStrategy.latest) { [weak self] (aUser) -> SignalProducer<GZEUser, GZEError> in

                    guard let this = self else {
                        log.error("Unable to complete the task. Self has been disposed.")
                        return SignalProducer(error: .repository(error: .UnexpectedError))
                    }

                    let user = GZEUser(id: aUser.id, username: aUser.username, email: aUser.email)
                    user.searchPic = aUser.searchPic

                    return this.update(user)
            }

        } else {
            return SignalProducer(error: .validation(error: .required(fieldName: GZEUser.Validation.searchPic.fieldName)))
        }

    }

    func savePhotos(_ user: GZEUser) -> SignalProducer<GZEUser, GZEError> {

            if let photos = user.photos, photos.count > 0 {
                return storageRepository.uploadFiles(photos.enumerated().flatMap { (index, photo) in

                    var imageData: Data?

                    if let image = photo.image {

                        imageData = UIImageJPEGRepresentation(image, 1)

                        return GZEFile(name: photo.name ?? "pic-\(index).jpg", size: imageData?.count ?? 0, container: GZEUser.Photo.container, type: "image/jpeg", data: imageData)
                    } else {
                        return nil
                    }
                }, container: GZEUser.Photo.container)
                .flatMap(FlattenStrategy.latest, transform: { files -> SignalProducer<GZEUser, GZEError> in

                    return SignalProducer<GZEUser, GZEError> { sink, disposable in

                        for file in files {
                            log.debug(file.toJSON() as Any)
                            log.debug(user.toJSON() as Any)

                            user.setPhoto(fromFile: file)
                        }

                        sink.send(value: user)
                        sink.sendCompleted()
                    }
                })
                .flatMap(FlattenStrategy.latest) { [weak self] (aUser) -> SignalProducer<GZEUser, GZEError> in

                    guard let this = self else {
                        log.error("Unable to complete the task. Self has been disposed.")
                        return SignalProducer(error: .repository(error: .UnexpectedError))
                    }

                    let user = GZEUser(id: aUser.id, username: aUser.username, email: aUser.email)
                    user.photos = aUser.photos

                    return this.update(user)
                }

            } else {
                return SignalProducer(error: .validation(error: .required(fieldName: GZEUser.Validation.galleryPics.fieldName)))
            }

    }

    func signUp(username: String, email: String, password: String, userJSON: JSON? = nil) -> SignalProducer<GZEUser, GZEError> {

        return SignalProducer<GZEAccesToken, GZEError> {[weak self] sink, disposable in

            disposable.add {
                log.debug("login SignalProducer disposed")
            }

            guard let this = self else {
                log.error("Unable to complete the task. Self has been disposed.")
                sink.send(error: .repository(error: .UnexpectedError))
                return
            }

            var unwrappedUserJSON: JSON
            if userJSON == nil {
                unwrappedUserJSON = JSON()
            } else {
                unwrappedUserJSON = userJSON!
            }

            unwrappedUserJSON["username"] = username
            unwrappedUserJSON["email"] = email
            unwrappedUserJSON["password"] = password

            let parameters: JSON = [
                "user": unwrappedUserJSON,
                "configName": GZEAppConfig.environment.rawValue
            ]

            Alamofire.request(GZEUserRouter.signUp(parameters: parameters))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: this.handleLoginResponse))

        }.flatMap(FlattenStrategy.latest) { (token: GZEAccesToken) -> SignalProducer<GZEUser, GZEError> in
            if let user = token.user {
                return SignalProducer(value: user)
            } else {
                log.error("Received token doesn't include the user.")
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }
        }
    }

    private let emailRule = ValidationRuleLength(min: 1, error: GZEValidationError.required(fieldName: GZEUser.Validation.username.fieldName))
    private let passwordRule = ValidationRuleLength(min: 1, error: GZEValidationError.required(fieldName: GZEUser.Validation.password.fieldName))

    private func validateLogin(_ email: String?, _ password: String?) -> VValidationResult {
        let result = Validator.validate(input: email, rule: emailRule)
            .merge(with: Validator.validate(input: password, rule: passwordRule))

        log.debug(result)

        return result
    }

    private func handleLoginResponse(json: JSON) -> GZEAccesToken? {
        let accessToken = GZEAccesToken(json: json)
        if accessToken != nil && accessToken!.user != nil {
            GZEAuthService.shared.login(token: accessToken!, user: accessToken!.user!)
        }
        return accessToken
    }


    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
