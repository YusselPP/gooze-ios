//
//  GZERatingsViewModelMe.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/1/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZERatingsViewModelMe: GZEProfileViewModelMe, GZERatingsViewModel {

    // MARK - GZERatingsViewModel protocol

    let username = MutableProperty<String?>(nil)

    let profilePic = MutableProperty<URLRequest?>(nil)

    let phrase = MutableProperty<String?>(nil)
    var phraseButtonAction: CocoaAction<UIButton>? = nil

    let imagesRatingDesc = MutableProperty<String?>(nil)
    let complianceRatingDesc = MutableProperty<String?>(nil)
    let dateQualityRatingDesc = MutableProperty<String?>(nil)
    let dateRatingDesc = MutableProperty<String?>(nil)
    let goozeRatingDesc = MutableProperty<String?>(nil)
    let overallRatingDesc = MutableProperty<String?>(nil)

    let imagesRating = MutableProperty<Float?>(nil)
    let complianceRating = MutableProperty<Float?>(nil)
    let dateQualityRating = MutableProperty<Float?>(nil)
    let dateRating = MutableProperty<Float?>(nil)
    let goozeRating = MutableProperty<Float?>(nil)
    let overallRating = MutableProperty<Float?>(nil)

    let imagesRatingIsEditable = MutableProperty<Bool>(false)
    let complianceRatingIsEditable = MutableProperty<Bool>(false)
    let dateQualityRatingIsEditable = MutableProperty<Bool>(false)
    let dateRatingIsEditable = MutableProperty<Bool>(false)
    let goozeRatingIsEditable = MutableProperty<Bool>(false)

    let (disposeToActivateGooze, _) = Signal<Void, NoError>.pipe()
    let (segueToProfile, _) = Signal<Void, NoError>.pipe()

    lazy var profileViewModel: GZEProfileUserInfoViewModel = {
        return GZEProfileUserInfoViewModelMe(self.user)
    }()

    // END - GZERatingsViewModel protocol

    // MARK - init
    override init(_ user: GZEUser) {
        super.init(user)
        log.debug("\(self) init")

        populate(user)
    }

    private func populate(_ user: GZEUser) {
        username.value = user.username.uppercased()

        profilePic.value = user.profilePic?.urlRequest

        phrase.value = user.topComment.map{"\"\($0)\""}

        imagesRatingDesc.value = GZEUser.Validation.imagesRating.fieldName
        complianceRatingDesc.value = GZEUser.Validation.complianceRating.fieldName
        dateQualityRatingDesc.value = GZEUser.Validation.dateQualityRating.fieldName
        dateRatingDesc.value = GZEUser.Validation.dateRating.fieldName
        goozeRatingDesc.value = GZEUser.Validation.goozeRating.fieldName

        imagesRating.value = user.imagesRating?.rate ?? 0
        complianceRating.value = user.complianceRating?.rate ?? 0
        dateQualityRating.value = user.dateQualityRating?.rate ?? 0
        dateRating.value = user.dateRating?.rate ?? 0
        goozeRating.value = user.goozeRating?.rate ?? 0
        overallRating.value = user.overallRating
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
