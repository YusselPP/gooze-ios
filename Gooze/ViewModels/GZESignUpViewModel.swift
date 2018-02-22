//
//  GZESignUpViewModel.swift
//  Gooze
//
//  Created by Yussel on 10/26/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import iCarousel
import Validator

class GZESignUpViewModel: NSObject, iCarouselDataSource, UIPickerViewDataSource {

    let userRepository: GZEUserRepositoryProtocol
    let user: GZEUser

    let usernameLabelText = GZEUser.Validation.username.fieldName
    let emailLabelText = GZEUser.Validation.email.fieldName
    let passwordLabelText = GZEUser.Validation.password.fieldName
    let registerCodeLabelText = GZEUser.Validation.registerCode.fieldName

    let phraseLabelText = GZEUser.Validation.phrase.fieldName
    let genderLabelText = GZEUser.Validation.gender.fieldName
    let birthdayLabelText = GZEUser.Validation.birthday.fieldName
    let heightLabelText = GZEUser.Validation.height.fieldName
    let weightLabelText = GZEUser.Validation.weight.fieldName
    let originLabelText = GZEUser.Validation.origin.fieldName
    let languageLabelText = GZEUser.Validation.language.fieldName
    let interestsLabelText = GZEUser.Validation.interestedIn.fieldName

    let viewTitle = "vm.signUp.viewTitle".localized()
    let facebookSignUp = "vm.signUp.facebookSignUpButtonTitle".localized()
    let createProfileText = "vm.signUp.createProfileText".localized()
    let skipProfileText = "vm.signUp.skipProfileText".localized()
    let successfulSignUp = "vm.signUp.success".localized()

    let profilePictureLabel = "vm.signUp.profilePictureLabel".localized()
    let searchPictureLabel = "vm.signUp.searchPictureLabel".localized()
    let blurButtonTitle = "vm.signUp.blurButtonTitle".localized()
    let nextButtonTitle = "vm.signUp.nextButtonTitle".localized()

    // basic sign up
    let username = MutableProperty<String?>(nil)
    let email = MutableProperty<String?>(nil)
    let password = MutableProperty<String?>(nil)
    let registerCode = MutableProperty<String?>(nil)

    let isBasicNextButtonEnabled = MutableProperty<Bool>(false)

    // additional data
    let birthday = MutableProperty<Date?>(nil)
    let gender = MutableProperty<GZEUser.Gender?>(nil)
    let weight = MutableProperty<String?>(nil)
    let height = MutableProperty<String?>(nil)
    let origin = MutableProperty<String?>(nil)
    let phrase = MutableProperty<String?>(nil)
    let languages = MutableProperty<String?>(nil)
    let interestedIn = MutableProperty<String?>(nil)

    let profilePic = MutableProperty<UIImage?>(nil)
    let searchPic = MutableProperty<UIImage?>(nil)

    var photos = [MutableProperty<GZEUser.Photo?>]()

    let mainImage = MutableProperty<UIImage?>(nil)

    let genders: [GZEUser.Gender?]

    enum validationRule {
        case username
        case email
        case password

        var stringRules: ValidationRuleSet<String>? {
            switch self {
            case .username:
                return GZEUser.Validation.username.stringRule()
            case .email:
                return GZEUser.Validation.email.stringRule()
            case .password:
                return GZEUser.Validation.password.stringRule()
            }
        }
    }


    var saveAction: Action<Void, GZEUser, GZEError> {
        if let saveAction = _saveAction {
            return saveAction
        }
        _saveAction = createSaveAction()
        return _saveAction!
    }
    private var _saveAction: Action<Void, GZEUser, GZEError>?

    var updateAction: Action<Void, GZEUser, GZEError> {
        if let updateAction = _updateAction {
            return updateAction
        }
        _updateAction = createUpdateAction()
        return _updateAction!
    }
    private var _updateAction: Action<Void, GZEUser, GZEError>?

    var savePhotosAction: Action<Void, GZEUser, GZEError> {
        if let savePhotosAction = _savePhotosAction {
            return savePhotosAction
        }
        _savePhotosAction = createSavePhotosAction()
        return _savePhotosAction!
    }
    private var _savePhotosAction: Action<Void, GZEUser, GZEError>?

    var saveProfilePicAction: Action<Void, GZEUser, GZEError> {
        if let saveProfilePicAction = _saveProfilePicAction {
            return saveProfilePicAction
        }
        _saveProfilePicAction = createSaveProfilePicAction()
        return _saveProfilePicAction!
    }
    private var _saveProfilePicAction: Action<Void, GZEUser, GZEError>?

    var saveSearchPicAction: Action<Void, GZEUser, GZEError> {
        if let saveSearchPicAction = _saveSearchPicAction {
            return saveSearchPicAction
        }
        _saveSearchPicAction = createSaveSearchPicAction()
        return _saveSearchPicAction!
    }
    private var _saveSearchPicAction: Action<Void, GZEUser, GZEError>?


    init(_ userRepository: GZEUserRepositoryProtocol) {
        self.userRepository = userRepository
        self.user = GZEUser()

        var genders: [GZEUser.Gender?] = GZEUser.Gender.array
        genders.insert(nil, at: 0)
        self.genders = genders

        super.init()

        log.debug("\(self) init")
    }

    private func createSaveAction() -> Action<Void, GZEUser, GZEError> {
        log.debug("Creating save action")
        return Action<Void, GZEUser, GZEError>{[weak self] in
            guard let strongSelf = self else {
                log.error("self disposed")
                return SignalProducer(error: GZEError.repository(error: .UnexpectedError))
            }
            strongSelf.fillUser()
            return strongSelf.userRepository.signUp(strongSelf.user)
        }
    }

    private func createUpdateAction() -> Action<Void, GZEUser, GZEError> {
        log.debug("Creating update action")
        return Action<Void, GZEUser, GZEError>{[weak self] in
            guard let this = self else {
                log.error("self disposed")
                return SignalProducer(error: GZEError.repository(error: .UnexpectedError))
            }

            guard let userId = GZEApi.instance.accessToken?.userId else {
                return SignalProducer(error: GZEError.repository(error: .AuthRequired))
            }

            this.fillUser()
            this.user.id = userId

            log.debug("User data = \(this.user.toJSON() as Any)")

            return this.userRepository.update(this.user)
        }
    }

    private func createSavePhotosAction() -> Action<Void, GZEUser, GZEError> {
        log.debug("Creating save photos action")
        return Action<Void, GZEUser, GZEError>{[weak self] in
            guard let this = self else {
                log.error("self disposed")
                return SignalProducer(error: GZEError.repository(error: .UnexpectedError))
            }

            guard let userId = GZEApi.instance.accessToken?.userId else {
                return SignalProducer(error: GZEError.repository(error: .AuthRequired))
            }

            this.fillUser()
            this.user.id = userId

            return this.userRepository.savePhotos(this.user)
        }
    }

    private func createSaveProfilePicAction() -> Action<Void, GZEUser, GZEError> {
        log.debug("Creating save ProfilePic action")
        return Action<Void, GZEUser, GZEError>{[weak self] in
            guard let this = self else {
                log.error("self disposed")
                return SignalProducer(error: GZEError.repository(error: .UnexpectedError))
            }

            guard let userId = GZEApi.instance.accessToken?.userId else {
                return SignalProducer(error: GZEError.repository(error: .AuthRequired))
            }

            // this.fillUser()
            this.user.id = userId
            this.user.profilePic = this.profilePic.map{ GZEUser.Photo(image: $0) }.value

            return this.userRepository.saveProfilePic(this.user)
        }
    }

    private func createSaveSearchPicAction() -> Action<Void, GZEUser, GZEError> {
        log.debug("Creating save SearchPic action")
        return Action<Void, GZEUser, GZEError>{[weak self] in
            guard let this = self else {
                log.error("self disposed")
                return SignalProducer(error: GZEError.repository(error: .UnexpectedError))
            }

            guard let userId = GZEApi.instance.accessToken?.userId else {
                return SignalProducer(error: GZEError.repository(error: .AuthRequired))
            }

            // this.fillUser()
            this.user.id = userId
            this.user.searchPic = this.searchPic.map{ GZEUser.Photo(image: $0) }.value

            return this.userRepository.saveSearchPic(this.user)
        }
    }

    private func fillUser() {
        log.debug("fill user attributes")
        user.username = username.value
        user.email = email.value
        user.password = password.value

        if let birthday = birthday.value {
            user.birthday = birthday
        }
        if let gender = gender.value {
            user.gender = gender
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
        user.photos = photos.flatMap { $0.value }
        user.profilePic = profilePic.map{ GZEUser.Photo(image: $0) }.value
        user.searchPic = searchPic.map{ GZEUser.Photo(image: $0) }.value

        log.debug(user.toJSON() as Any)
    }

    // MARK: iCarousel data source protocol

    func numberOfItems(in carousel: iCarousel) -> Int {
        return photos.count
    }

    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {

        var itemView: UIImageView

        //reuse view if available, otherwise create a new view
        if let view = view as? UIImageView {
            itemView = view
        } else {
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))
            itemView.image = photos[index].value?.image
            itemView.contentMode = .scaleAspectFit
        }

        log.debug("item showed \(index)")
        return itemView
    }

    // MARK: genderPicker data source protocol

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
