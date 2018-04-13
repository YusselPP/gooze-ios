//
//  GZEUpdateProfileViewModel.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/4/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Validator

class GZEUpdateProfileViewModel: NSObject {
    
    let userRepository: GZEUserRepositoryProtocol
    var user: GZEUser {
        didSet {
            username.value = self.user.username
            email.value = self.user.email
            //password.value = self.user.password
            registerCode.value = self.user.registerCode
            
            phrase.value = self.user.phrase
            gender.value = self.user.gender
            birthday.value = self.user.birthday
            if let newHeight = self.user.height {
                height.value = "\(newHeight)"
            }
            if let newWeight = self.user.weight {
                weight.value = "\(newWeight)"
            }
            origin.value = self.user.origin
            languages.value = self.user.languages?.first
            interestedIn.value = self.user.interestedIn?.first
        }
    }
    
    var dismiss: (() -> ())?
    
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
    let heightPickerDatasource: GZEPickerDatasource<String>
    let heightPickerDelegate: GZEPickerDelegate<String>
    let weightPickerDatasource: GZEPickerDatasource<String>
    let weightPickerDelegate: GZEPickerDelegate<String>
    
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
    
    
    init(_ userRepository: GZEUserRepositoryProtocol, user: GZEUser) {
        self.userRepository = userRepository
        self.user = user
        
        var genders: [GZEUser.Gender?] = GZEUser.Gender.array
        genders.insert(nil, at: 0)
        let gendersTitles = genders.map { $0?.displayValue }
        
        self.genderPickerDelegate = GZEPickerDelegate(titles: [gendersTitles], elements: [genders])
        self.genderPickerDatasource = GZEPickerDatasource(elements: [genders])
        
        let heightInteger = ["0", "1", "2"]
        let heightDecimals = (0...9).map{ "\($0)" }
        let heightTitles = [heightInteger, ["."], heightDecimals, heightDecimals, [GZEUser.heightUnit]]
        let heightValues = [heightInteger, ["."], heightDecimals, heightDecimals, [""]]
        self.heightPickerDelegate = GZEPickerDelegate(titles: heightTitles, elements: heightValues)
        self.heightPickerDatasource = GZEPickerDatasource(elements: heightValues)
        self.heightPickerDelegate.width = 50
        
        let weightFirstDigit = ["0", "1"]
        let weightNumbers = (0...9).map{ "\($0)" }
        let weightTitles = [weightFirstDigit, weightNumbers, weightNumbers, [GZEUser.weightUnit]]
        let weightValues = [weightFirstDigit, weightNumbers, weightNumbers, [""]]
        self.weightPickerDelegate = GZEPickerDelegate(titles: weightTitles, elements: weightValues)
        self.weightPickerDatasource = GZEPickerDatasource(elements: weightValues)
        self.weightPickerDelegate.width = 50
        
        super.init()
        
        log.debug("\(self) init")
        
        self.gender <~ self.genderPickerDelegate.selectedElements.map { gA -> (GZEUser.Gender?) in
            let gender = (gA.first.flatMap{$0.flatMap{$0}})
            log.debug("saved gender: \(String(describing: gender))")
            return gender
        }
        
        self.height <~ self.heightPickerDelegate.selectedElements.map{ $0.reduce("", { $0 + ($1 ?? "") }) }
        self.weight <~ self.weightPickerDelegate.selectedElements.map{ "\(($0.reduce("", { $0 + ($1 ?? "") }) as NSString).intValue)" }
        
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
        
        
        Signal.merge(
            signupAction.values,
            updateAction.values,
            savePhotosAction.values,
            saveProfilePicAction.values,
            saveSearchPicAction.values
            )
            .observeValues {[weak self] user in
                log.debug("user updated: \(user.toJSON() as  Any)")
                GZEAuthService.shared.authUser = user
                self?.user = user
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
        
        guard let aUsername = username.value else {
            return SignalProducer(error: .validation(error: .required(fieldName: GZEUser.Validation.username.fieldName)))
        }
        
        guard let aEmail = username.value else {
            return SignalProducer(error: .validation(error: .required(fieldName: GZEUser.Validation.email.fieldName)))
        }
        
        guard let aPassword = username.value else {
            return SignalProducer(error: .validation(error: .required(fieldName: GZEUser.Validation.password.fieldName)))
        }
        
        return self.userRepository.signUp(username: aUsername, email: aEmail, password: aPassword)
    }
    
    private func onUpdateAction() -> SignalProducer<GZEUser, GZEError> {
        
        fillUser()
        
        log.debug("User data = \(user.toJSON() as Any)")
        
        return self.userRepository.update(user)
    }
    
    private func onSavePhotosAction() -> SignalProducer<GZEUser, GZEError> {
        
        // TODO: remove old photos from server
        self.user.photos = (
            self.thumbnails
                .flatMap{ GZEUser.Photo(image:$0.value) }
        )
        
        return self.userRepository.savePhotos(self.user)
    }
    
    private func onSaveProfilePicAction() -> SignalProducer<GZEUser, GZEError> {
        self.user.profilePic = self.profilePic.map{ GZEUser.Photo(image: $0) }.value
        
        return self.userRepository.saveProfilePic(self.user)
    }
    
    private func onSaveSearchPicAction() -> SignalProducer<GZEUser, GZEError> {
        self.user.searchPic = self.searchPic.map{ GZEUser.Photo(image: $0) }.value
        
        return self.userRepository.saveSearchPic(self.user)
    }
    
    private func fillUser() {
        if let birthday = birthday.value {
            self.user.birthday = birthday
        }
        if let gender = gender.value {
            self.user.gender = gender
        }
        self.user.weight = (weight.value as NSString?)?.floatValue
        self.user.height = (height.value as NSString?)?.floatValue
        self.user.origin = origin.value
        self.user.phrase = phrase.value
        if let language = languages.value {
            self.user.languages = [language]
        }
        if let interestedIn = interestedIn.value {
            self.user.interestedIn = [interestedIn]
        }
        
        log.debug(self.user.toJSON() as Any)
    }
    
    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}

