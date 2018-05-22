//
//  GZERatingsViewModelReadOnly.swift
//  Gooze
//
//  Created by Yussel on 3/7/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZERatingsViewModelReadOnly: GZEProfileViewModelReadOnly, GZERatingsViewModel {

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
        return GZEProfileUserInfoViewModelReadOnly(user: self.user, dateRequest: self.dateRequest)
    }()

    // END - GZERatingsViewModel protocol

    // MARK - init
    override init(user: GZEUser, dateRequest: MutableProperty<GZEDateRequest?>) {
        super.init(user: user, dateRequest: dateRequest)
        log.debug("\(self) init")

        populate(user)
    }

    private func populate(_ user: GZEUser) {
        username.value = user.username.uppercased()

        profilePic.value = user.profilePic?.urlRequest

        // TODO: Where does this come from?
        phrase.value = "\"Usuario altamente recomendado por Gooze\""

        imagesRatingDesc.value = GZEUser.Validation.imagesRating.fieldName
        complianceRatingDesc.value = GZEUser.Validation.complianceRating.fieldName
        dateQualityRatingDesc.value = GZEUser.Validation.dateQualityRating.fieldName
        dateRatingDesc.value = GZEUser.Validation.dateRating.fieldName
        goozeRatingDesc.value = GZEUser.Validation.goozeRating.fieldName

        imagesRating.value = user.imagesRating?.rate
        complianceRating.value = user.complianceRating?.rate
        dateQualityRating.value = user.dateQualityRating?.rate
        dateRating.value = user.dateRating?.rate
        goozeRating.value = user.goozeRating?.rate
        overallRating.value = user.overallRating
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
