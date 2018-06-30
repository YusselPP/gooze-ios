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
            populate()
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
    let genderSearchForLabelText = "vm.signUp.genderSearchLabelText".localized()

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
    let profilePicRequest = MutableProperty<URLRequest?>(nil)
    let searchPic = MutableProperty<UIImage?>(nil)
    
    let mainImage = MutableProperty<UIImage?>(nil)
    let mainImageRequest = MutableProperty<URLRequest?>(nil)
    let genderOptions = GZEUser.Gender.array
    
    var thumbnails = [
        MutableProperty<UIImage?>(nil),
        MutableProperty<UIImage?>(nil),
        MutableProperty<UIImage?>(nil),
        MutableProperty<UIImage?>(nil)
    ]

    var thumbnailsRequest = [
        MutableProperty<URLRequest?>(nil),
        MutableProperty<URLRequest?>(nil),
        MutableProperty<URLRequest?>(nil),
        MutableProperty<URLRequest?>(nil)
    ]
    
    let genderPickerDatasource: GZEPickerDatasource<GZEUser.Gender?>
    let genderPickerDelegate: GZEPickerDelegate<GZEUser.Gender?>
    let heightPickerDatasource: GZEPickerDatasource<String>
    let heightPickerDelegate: GZEPickerDelegate<String>
    let weightPickerDatasource: GZEPickerDatasource<String>
    let weightPickerDelegate: GZEPickerDelegate<String>
    let interestPickerDatasource: GZEPickerDatasource<String>
    let interestPickerDelegate: GZEPickerDelegate<String>

    let skipButtonIsHidden = MutableProperty<Bool>(false)
    let phraseTextFieldIsHidden = MutableProperty<Bool>(true)
    let phraseTopLineIsHidden = MutableProperty<Bool>(true)
    let phraseBotLineIsHidden = MutableProperty<Bool>(true)
    let genderTextFieldIsHidden = MutableProperty<Bool>(true)
    let birthdayTextFieldIsHidden = MutableProperty<Bool>(true)
    let heightTextFieldIsHidden = MutableProperty<Bool>(true)
    let weightTextFieldIsHidden = MutableProperty<Bool>(true)
    let originTextFieldIsHidden = MutableProperty<Bool>(true)
    let languageTextFieldIsHidden = MutableProperty<Bool>(true)
    let interestsTextFieldIsHidden = MutableProperty<Bool>(true)
    let searchForGenderLabelIsHidden = MutableProperty<Bool>(true)

    let navigationRightButton = MutableProperty<UIBarButtonItem?>(nil)
    
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

    let searchForGenderLabel = MutableProperty<String?>(nil)
    let searchForGender = MutableProperty<[Int]>([])

    var genderCheckListVM: GZECheckListViewModel {
        return GZECheckListViewModel(options: self.genderOptions.map{$0.displayValue}, selectedIndexes: self.searchForGender, title: genderSearchForLabelText)
    }

    var paymentViewModel: GZEPaymentMethodsViewModelAdded {
        return GZEPaymentMethodsViewModelAdded()
    }
    
    var usernameExistsAction: Action<Void, Bool, GZEError>!
    var emailExistsAction: Action<Void, Bool, GZEError>!
    var updateAction: Action<Void, GZEUser, GZEError>!
    var savePhotosAction: Action<Void, GZEUser, GZEError>!
    var saveProfilePicAction: Action<Void, GZEUser, GZEError>!
    var saveSearchPicAction: Action<Void, GZEUser, GZEError>!
    
    
    init(_ userRepository: GZEUserRepositoryProtocol, user: GZEUser, mutableUser: MutableProperty<GZEUser>? = nil) {
        self.userRepository = userRepository
        self.user = user
        
        var genders: [GZEUser.Gender?] = GZEUser.Gender.array
        genders.insert(nil, at: 0)
        let gendersTitles = genders.map { $0?.displayValue }
        
        self.genderPickerDelegate = GZEPickerDelegate(titles: [gendersTitles], elements: [genders])
        self.genderPickerDatasource = GZEPickerDatasource(elements: [genders])
        // Autoselect first element of each component
        self.genderPickerDelegate.selectedElements.value = [genders].map{ $0.first! }
        
        let heightInteger = ["0", "1", "2"]
        let heightDecimals = (0...9).map{ "\($0)" }
        let heightTitles = [heightInteger, ["."], heightDecimals, heightDecimals, [GZEUser.heightUnit]]
        let heightValues = [heightInteger, ["."], heightDecimals, heightDecimals, [""]]
        self.heightPickerDelegate = GZEPickerDelegate(titles: heightTitles, elements: heightValues)
        self.heightPickerDatasource = GZEPickerDatasource(elements: heightValues)
        self.heightPickerDelegate.width = 50
        // Autoselect first element of each component
        self.heightPickerDelegate.selectedElements.value = heightValues.map{ $0.first! }
        
        let weightFirstDigit = ["0", "1"]
        let weightNumbers = (0...9).map{ "\($0)" }
        let weightTitles = [weightFirstDigit, weightNumbers, weightNumbers, [GZEUser.weightUnit]]
        let weightValues = [["", "1"], weightNumbers, weightNumbers, [""]]
        self.weightPickerDelegate = GZEPickerDelegate(titles: weightTitles, elements: weightValues)
        self.weightPickerDatasource = GZEPickerDatasource(elements: weightValues)
        self.weightPickerDelegate.width = 50
        // Autoselect first element of each component
        self.weightPickerDelegate.selectedElements.value = weightValues.map{ $0.first! }

        let interestTitles = [[
            "",
            "vm.signUp.interests.friendlyDates",
            "vm.signUp.interests.searchPartner",
            "vm.signUp.interests.sporadicDates",
            "vm.signUp.interests.littleBitOfEvth",
            ]]
        self.interestPickerDelegate = GZEPickerDelegate(titles: interestTitles.map{$0.map{$0.localized()}}, elements: interestTitles)
        self.interestPickerDatasource = GZEPickerDatasource(elements: interestTitles)
        self.interestPickerDelegate.width = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        self.interestPickerDelegate.selectedElements.value = interestTitles.map{ $0.first! }

        
        super.init()
        
        log.debug("\(self) init")

        self.populate()
        
        self.gender <~ self.genderPickerDelegate.selectedElements.map { gA -> (GZEUser.Gender?) in
            let gender = (gA.first.flatMap{$0.flatMap{$0}})
            log.debug("saved gender: \(String(describing: gender))")
            return gender
        }
        self.searchForGenderLabel <~ (
            self.searchForGender.map {[weak self] selectedIdx -> String? in
                guard selectedIdx.count > 0 else {
                    return self?.genderSearchForLabelText
                }

                return selectedIdx.sorted()
                    .flatMap{[weak self] in self?.genderOptions[$0].displayValue}
                    .joined(separator: ", ")
            }
        )
        
        self.height <~ self.heightPickerDelegate.selectedElements.map{ $0.reduce("", { $0 + $1 }) }
        self.weight <~ self.weightPickerDelegate.selectedElements.map{ $0.reduce("", { $0 + $1 }) }
        self.interestedIn <~ self.interestPickerDelegate.selectedElements.map{ $0.first! }
        
        usernameExistsAction = Action { [unowned self] in
            return self.onUsernameExistsAction()
        }
        emailExistsAction = Action { [unowned self] in
            return self.onEmailExistsAction()
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
            updateAction.values,
            savePhotosAction.values,
            saveProfilePicAction.values,
            saveSearchPicAction.values
        )
            .observeValues { user in
                log.debug("user updated: \(user.toJSON() as  Any)")
                GZEAuthService.shared.authUser = user
                // self?.user = user
                mutableUser?.value = user
            }

        saveProfilePicAction.values.observeValues{[weak self] user in
            guard let this = self else {return}
            this.profilePicRequest.value = user.profilePic?.urlRequest
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

    
    private func onUpdateAction() -> SignalProducer<GZEUser, GZEError> {
        
        fillUser()
        
        log.debug("User data = \(user.toJSON() as Any)")
        
        return self.userRepository.update(user)
    }
    
    private func onSavePhotosAction() -> SignalProducer<GZEUser, GZEError> {
        
        if self.user.photos == nil {
            self.user.photos = (
                self.thumbnails.enumerated()
                    .map{ GZEUser.Photo(image: $0.element.value, name: "\(self.user.id)_gallery_\($0.offset).jpg") }
            )
        } else {
            for (index, image) in self.thumbnails.enumerated() {
                if image.value == nil {
                    continue
                }

                if index >= self.user.photos!.count {
                    log.error("Index out of bounds")
                    break
                }

                self.user.photos![index] = GZEUser.Photo(image: image.value, name: "\(self.user.id)_gallery_\(index).jpg")
            }
        }

        return self.userRepository.savePhotos(self.user)
    }
    
    private func onSaveProfilePicAction() -> SignalProducer<GZEUser, GZEError> {
        self.user.profilePic = self.profilePic.map{ GZEUser.Photo(image: $0, name: "\(self.user.id)_profile.jpg") }.value
        
        return self.userRepository.saveProfilePic(self.user)
    }
    
    private func onSaveSearchPicAction() -> SignalProducer<GZEUser, GZEError> {
        self.user.searchPic = self.searchPic.map{ GZEUser.Photo(image: $0, name: "\(self.user.id)_search.jpg") }.value
        
        return self.userRepository.saveSearchPic(self.user)
    }

    private func populate() {
        log.debug("user did set: \(self.user.toJSON())")

        profilePicRequest.value = self.user.profilePic?.urlRequest

        username.value = self.user.username
        email.value = self.user.email
        //password.value = self.user.password
        registerCode.value = self.user.registerCode

        phrase.value = self.user.phrase

        if let gender = self.user.gender {
            genderPickerDelegate.selectedElements.value[0] = gender
        }

        if let userSearchForGender = self.user.searchForGender {
            searchForGender.value = userSearchForGender.flatMap{
                [weak self] searchGender in
                self?.genderOptions.index(where: {$0 == searchGender})
            }
        }
        birthday.value = self.user.birthday

        if let newHeight = self.user.height {
            var arr = Array(newHeight.format(f: ".2")).map{String($0)}
            arr.append("")
            log.debug("\(arr)")
            heightPickerDelegate.selectedElements.value = arr
        }
        if let newWeight = self.user.weight {
            var arr = Array(newWeight.format(f: "3.0")).map{String($0)}
            arr.append("")
            log.debug("\(arr)")
            weightPickerDelegate.selectedElements.value = arr
        }

        origin.value = self.user.origin
        languages.value = self.user.languages?.first
        if let interest = self.user.interestedIn?.first {
            interestPickerDelegate.selectedElements.value[0] = interest
        }

        // gallery
        if let photos = self.user.photos {
            for (index, photo) in photos.enumerated() {
                if index >= thumbnailsRequest.count {
                    log.warning("index out of bounds")
                    break
                }
                thumbnailsRequest[index].value = photo.urlRequest
            }
        }
    }

    private func fillUser() {
        if let birthday = birthday.value {
            self.user.birthday = birthday
        }
        if let gender = gender.value {
            self.user.gender = gender
        }
        self.user.searchForGender = self.searchForGender.value.sorted().flatMap{
            [weak self] in
            guard let this = self else {return nil}
            return this.genderOptions[$0]
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

