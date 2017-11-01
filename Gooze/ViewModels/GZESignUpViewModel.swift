//
//  GZESignUpViewModel.swift
//  Gooze
//
//  Created by Yussel on 10/26/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift

class GZESignUpViewModel {

    let userRepository: GZEUserRepositoryProtocol
    let user: GZEUser

    // basic sign up
    let username = MutableProperty<String?>("")
    let email = MutableProperty<String?>("")
    let password = MutableProperty<String?>("")

    // additional data
    let birthday = MutableProperty<String?>("")
    let gender = MutableProperty<String?>("")
    let weight = MutableProperty<String?>("")
    let height = MutableProperty<String?>("")
    let origin = MutableProperty<String?>("")
    let phrase = MutableProperty<String?>("")
    let languages = MutableProperty<String?>("")
    let interestedIn = MutableProperty<String?>("")


    var saveAction: Action<Void, GZEUser, GZERepositoryError> {
        if let saveAction = _saveAction {
            return saveAction
        }
        _saveAction = createSaveAction()
        return _saveAction!
    }
    private var _saveAction: Action<Void, GZEUser, GZERepositoryError>?


    init(_ userRepository: GZEUserRepositoryProtocol) {
        self.userRepository = userRepository
        self.user = GZEUser()
        log.debug("\(self) init")
    }

    private func createSaveAction() -> Action<Void, GZEUser, GZERepositoryError> {
        log.debug("Creating save action")
        return Action<Void, GZEUser, GZERepositoryError>{[weak self] in
            guard let strongSelf = self else { return SignalProducer.empty }
            strongSelf.fillUser()
            return strongSelf.userRepository.create(strongSelf.user)
        }
    }

    private func fillUser() {
        log.debug("fill user attributes")
        user.username = username.value
        user.email = email.value
        user.password = password.value

        if let birthday = birthday.value {
            user.birthday = DateFormatter().date(from: birthday)
        }
        if let gender = gender.value {
            user.gender = GZEUser.Gender(rawValue: gender)
        }
        user.weight = (weight.value as NSString?)?.floatValue
        user.height = (height.value as NSString?)?.floatValue
        user.origin = origin.value
        user.phrase = phrase.value
        if let language = languages.value {
            user.languages = [language]
        }
        if let interestedIn = interestedIn.value {
            user.interestedIn = [interestedIn]
        }
        log.debug(user)
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
