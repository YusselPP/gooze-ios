//
//  GZEProfileUserInfoViewModelReadOnly.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/1/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZEProfileUserInfoViewModelReadOnly: GZEProfileViewModelReadOnly, GZEProfileUserInfoViewModel {

    // MARK - GZEProfileUserInfoViewModel protocol
    
    // basic data
    let username = MutableProperty<String?>(nil)
    let profilePic = MutableProperty<URLRequest?>(nil)
    
    // additional data
    let phrase = MutableProperty<String?>(nil)
    let age = MutableProperty<String?>(nil)
    let gender = MutableProperty<String?>(nil)
    let height = MutableProperty<String?>(nil)
    let weight = MutableProperty<String?>(nil)
    let origin = MutableProperty<String?>(nil)
    let languages = MutableProperty<String?>(nil)
    let interestedIn = MutableProperty<String?>(nil)
    // TODO: Implement ocupation in user model
    let ocupation = MutableProperty<String?>(nil)

    let ageAction = MutableProperty<CocoaAction<UIButton>?>(nil)
    let genderAction = MutableProperty<CocoaAction<UIButton>?>(nil)
    let heightAction = MutableProperty<CocoaAction<UIButton>?>(nil)
    let weightAction = MutableProperty<CocoaAction<UIButton>?>(nil)
    let originAction = MutableProperty<CocoaAction<UIButton>?>(nil)
    let languagesAction = MutableProperty<CocoaAction<UIButton>?>(nil)
    let interestedInAction = MutableProperty<CocoaAction<UIButton>?>(nil)

    let (dismissSignal, _) = Signal<Void, NoError>.pipe()

    var editUserAction = MutableProperty<CocoaAction<GZEEditButton>?>(nil)
    var editUserButtonIsHidden = MutableProperty<Bool>(true)
    var (segueToUpdateProfile, _) = Signal<GZEUpdateProfileViewModel?, NoError>.pipe()
    
    
    // MARK - init
    override init(user: GZEUser, dateRequest: MutableProperty<GZEDateRequest?>) {
        super.init(user: user, dateRequest: dateRequest)
        log.debug("\(self) init")
        
        populate(user)
    }
    
    private func populate(_ user: GZEUser) {
        username.value = user.username.uppercased()
        
        if let birthday = user.birthday {
            self.age.value = "\(GZEDateHelper.years(from: birthday, to: Date())) \(GZEUser.ageUnit)"
        } else {
            self.age.value = GZEUser.ageLabel
        }
        if let uGender = user.gender {
            gender.value = uGender.displayValue
        } else {
            gender.value = GZEUser.Validation.gender.fieldName
        }
        if let uWeight = user.weight, uWeight != 0 {
            weight.value = "\(uWeight) \(GZEUser.weightUnit)"
        } else {
            weight.value = GZEUser.Validation.weight.fieldName
        }
        if let uHeight = user.height, uHeight != 0 {
            height.value = "\(uHeight) \(GZEUser.heightUnit)"
        } else {
            height.value = GZEUser.Validation.height.fieldName
        }
        if let origin = user.origin {
            self.origin.value = origin
        } else {
            self.origin.value = GZEUser.Validation.origin.fieldName
        }
        if let phrase = user.phrase {
            self.phrase.value = phrase
        } else {
            self.phrase.value = GZEUser.Validation.phrase.fieldName
        }
        if let languages = user.languages?.first {
            self.languages.value = languages
        } else {
            self.languages.value = GZEUser.Validation.language.fieldName
        }
        if let interestedIn = user.interestedIn?.first {
            self.interestedIn.value = interestedIn.localized()
        } else {
            self.interestedIn.value = GZEUser.Validation.interestedIn.fieldName
        }
        
        profilePic.value = user.profilePic?.urlRequest
    }
    
    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}

