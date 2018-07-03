//
//  GZEProfileUserInfoViewModelMe.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/1/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZEProfileUserInfoViewModelMe: GZEProfileViewModelMe, GZEProfileUserInfoViewModel {
    
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

    let ocupation = MutableProperty<String?>(nil)

    let ageAction = MutableProperty<CocoaAction<UIButton>?>(nil)
    let genderAction = MutableProperty<CocoaAction<UIButton>?>(nil)
    let heightAction = MutableProperty<CocoaAction<UIButton>?>(nil)
    let weightAction = MutableProperty<CocoaAction<UIButton>?>(nil)
    let originAction = MutableProperty<CocoaAction<UIButton>?>(nil)
    let languagesAction = MutableProperty<CocoaAction<UIButton>?>(nil)
    let interestedInAction = MutableProperty<CocoaAction<UIButton>?>(nil)

    let editUserAction = MutableProperty<CocoaAction<GZEEditButton>?>(nil)
    var editUserButtonIsHidden = MutableProperty<Bool>(false)

    let (dismissSignal, _) = Signal<Void, NoError>.pipe()
    let (segueToUpdateProfile, segueToUpdateProfileObs) = Signal<GZEUpdateProfileViewModel?, NoError>.pipe()
    // END GZEProfileUserInfoViewModel protocol

    override var user: GZEUser {
        didSet {
            populate(self.user)
        }
    }

    // MARK - init
    override init(_ user: GZEUser) {
        super.init(user)
        log.debug("\(self) init")

        populate(user)

        editUserAction.value = CocoaAction(createEditUserAction())
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

    private func createEditUserAction() -> Action<Void, Void, NoError> {
        return Action {[weak self] in
            guard let this = self else {return SignalProducer.empty}
            let mutableUser = MutableProperty(this.user)
            mutableUser.signal.observeValues {[weak self] in
                guard let this = self else {return}
                this.user = $0
            }
            this.segueToUpdateProfileObs.send(
                value: GZEUpdateProfileViewModel(this.userRepository, user: this.user, mutableUser: mutableUser)
            )
            return SignalProducer.empty
        }
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
