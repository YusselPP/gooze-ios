//
//  GZERatingsViewModelReadOnly.swift
//  Gooze
//
//  Created by Yussel on 3/7/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift

class GZERatingsViewModelReadOnly: GZEProfileViewModelReadOnly, GZERatingsViewModel {
    // MARK - GZERatingsViewModel protocol
    
    let username = MutableProperty<String?>(nil)

    let profilePic = MutableProperty<URLRequest?>(nil)

    let phrase = MutableProperty<String?>(nil)

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


    // MARK - init
    override init(user: GZEUser) {
        super.init(user: user)
        log.debug("\(self) init")

        populate(user)
    }

    private func populate(_ user: GZEUser) {
        username.value = user.username?.uppercased()

        profilePic.value = user.profilePic?.urlRequest

        // TODO: Where does this come from?
        phrase.value = "\"Usuario altamente recomendado por Gooze\""

        imagesRatingDesc.value = GZEUser.Validation.imagesRating.fieldName
        complianceRatingDesc.value = GZEUser.Validation.complianceRating.fieldName
        dateQualityRatingDesc.value = GZEUser.Validation.dateQualityRating.fieldName
        dateRatingDesc.value = GZEUser.Validation.dateRating.fieldName
        goozeRatingDesc.value = GZEUser.Validation.goozeRating.fieldName

        imagesRating.value = user.imagesRating ?? 0
        complianceRating.value = user.complianceRating ?? 0
        dateQualityRating.value = user.dateQualityRating ?? 0
        dateRating.value = user.dateRating ?? 0
        goozeRating.value = user.goozeRating ?? 0
        overallRating.value = user.overallRating ?? 0
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
