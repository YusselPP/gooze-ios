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

class GZESignUpViewModel: NSObject {

    let userRepository: GZEUserRepositoryProtocol
    var user: GZEUser {
        set(newUser) {
            username.value = newUser.username
            email.value = newUser.email
            password.value = newUser.password
            registerCode.value = newUser.registerCode

            phrase.value = newUser.phrase
            gender.value = newUser.gender
            birthday.value = newUser.birthday
            if let newHeight = newUser.height {
                height.value = "\(newHeight)"
            }
            if let newWeight = newUser.weight {
                weight.value = "\(newWeight)"
            }
            origin.value = newUser.origin
            languages.value = newUser.languages?.first
            interestedIn.value = newUser.interestedIn?.first
        }
        get { return _user! }
    }
    var _user: GZEUser?

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
    let applyBlurButtonTitle = "vm.signUp.applyBlurButtonTitle".localized()
    let nextButtonTitle = "vm.signUp.nextButtonTitle".localized()
    let saveButtonTitle = "vm.signUp.saveButtonTitle".localized()

    let textFieldValidationFailed = "vm.signUp.textField.validation.failed".localized()

    // basic sign up
    let username = MutableProperty<String?>(nil)
    let email = MutableProperty<String?>(nil)
    let password = MutableProperty<String?>(nil)
    let registerCode = MutableProperty<String?>(nil)

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

    let mainImage = MutableProperty<UIImage?>(nil)

    var thumbnails = [MutableProperty<UIImage?>](arrayLiteral:
        MutableProperty<UIImage?>(nil),
        MutableProperty<UIImage?>(nil),
        MutableProperty<UIImage?>(nil),
        MutableProperty<UIImage?>(nil)
    )

    let genderPickerDatasource: GZEPickerDatasource<GZEUser.Gender?>
    let genderPickerDelegate: GZEPickerDelegate<GZEUser.Gender?>

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

    var usernameExistsAction: Action<Void, Bool, GZEError>!
    var emailExistsAction: Action<Void, Bool, GZEError>!
    var signupAction: Action<Void, GZEUser, GZEError>!
    var updateAction: Action<Void, GZEUser, GZEError>!
    var savePhotosAction: Action<Void, GZEUser, GZEError>!
    var saveProfilePicAction: Action<Void, GZEUser, GZEError>!
    var saveSearchPicAction: Action<Void, GZEUser, GZEError>!


    init(_ userRepository: GZEUserRepositoryProtocol) {
        self.userRepository = userRepository
        self._user = GZEUser()

        var genders: [GZEUser.Gender?] = GZEUser.Gender.array
        genders.insert(nil, at: 0)
        let gendersTitles = genders.map { $0?.displayValue }

        self.genderPickerDelegate = GZEPickerDelegate(titles: [gendersTitles], elements: [genders])
        self.genderPickerDatasource = GZEPickerDatasource(elements: [genders])

        super.init()

        log.debug("\(self) init")

        self.gender <~ self.genderPickerDelegate.selectedElement.map { $0?.flatMap{ $0 } }

        usernameExistsAction = Action { [unowned self] in
            return self.onUsernameExistsAction()
        }
        emailExistsAction = Action { [unowned self] in
            return self.onEmailExistsAction()
        }
        signupAction = Action { [unowned self] in
            return self.onSignupAction()
        }
        updateAction = Action { [unowned self] in
            return self.onUpdateAction()
        }
        savePhotosAction = Action { [unowned self] in
            return self.onSavePhotosAction()
        }
        saveProfilePicAction = Action { [unowned self] in
            return self.onSaveProfilePicAction()
        }
        saveSearchPicAction = Action { [unowned self] in
            return self.onSaveSearchPicAction()
        }
    }

    func getChooseModeViewModel() -> GZEChooseModeViewModel {
        return GZEChooseModeViewModel(userRepository)
    }


    private func onUsernameExistsAction() -> SignalProducer<Bool, GZEError> {
        guard let username = username.value else {
            return SignalProducer(error: .validation(error: .required(fieldName: GZEUser.Validation.username.fieldName)))
        }

        return self.userRepository.usernameExists(username)
    }

    private func onEmailExistsAction() -> SignalProducer<Bool, GZEError> {
        guard let email = email.value else {
            return SignalProducer(error: .validation(error: .required(fieldName: GZEUser.Validation.email.fieldName)))
        }

        return self.userRepository.emailExists(email)
    }

    private func onSignupAction() -> SignalProducer<GZEUser, GZEError> {
        user.username = username.value
        user.email = email.value
        user.password = password.value

        log.debug("User data = \(user.toJSON() as Any)")

        return self.userRepository.signUp(user)
    }

    private func onUpdateAction() -> SignalProducer<GZEUser, GZEError> {
        guard let userId = GZEApi.instance.accessToken?.userId else {
            return SignalProducer(error: GZEError.repository(error: .AuthRequired))
        }

        fillUser()
        user.id = userId

        log.debug("User data = \(user.toJSON() as Any)")

        return self.userRepository.update(user)
    }

    private func onSavePhotosAction() -> SignalProducer<GZEUser, GZEError> {
        guard let userId = GZEApi.instance.accessToken?.userId else {
            return SignalProducer(error: GZEError.repository(error: .AuthRequired))
        }

        self.user.id = userId

        // TODO: remove old photos from server
        self.user.photos = (
            self.thumbnails
                .flatMap{ GZEUser.Photo(image:$0.value) }
        )

        return self.userRepository.savePhotos(self.user)
    }

    private func onSaveProfilePicAction() -> SignalProducer<GZEUser, GZEError> {
        guard let userId = GZEApi.instance.accessToken?.userId else {
            return SignalProducer(error: GZEError.repository(error: .AuthRequired))
        }

        self.user.id = userId
        self.user.profilePic = self.profilePic.map{ GZEUser.Photo(image: $0) }.value

        return self.userRepository.saveProfilePic(self.user)
    }

    private func onSaveSearchPicAction() -> SignalProducer<GZEUser, GZEError> {
        guard let userId = GZEApi.instance.accessToken?.userId else {
            return SignalProducer(error: GZEError.repository(error: .AuthRequired))
        }

        self.user.id = userId
        self.user.searchPic = self.searchPic.map{ GZEUser.Photo(image: $0) }.value

        return self.userRepository.saveSearchPic(self.user)
    }

    private func fillUser() {
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

        log.debug(user.toJSON() as Any)
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
