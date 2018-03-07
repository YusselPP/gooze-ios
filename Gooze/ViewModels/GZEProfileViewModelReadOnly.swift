//
//  GZEProfileViewModelReadOnly.swift
//  Gooze
//
//  Created by Yussel on 3/5/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift

class GZEProfileViewModelReadOnly: NSObject, GZEProfileViewModel {

    // MARK - GZEProfileViewModel protocol
    // basic data
    let username = MutableProperty<String?>(nil)

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

    let profilePic = MutableProperty<URLRequest?>(nil)

    func contact() {
    }


    // MARK - init
    init(user: GZEUser) {
        super.init()
        log.debug("\(self) init")

        populate(user)
    }

    private func populate(_ user: GZEUser) {
        username.value = user.username?.uppercased()

        age.value = user.birthday.map{ "\(GZEDateHelper.years(from: $0, to: Date())) años" }
        if let uGender = user.gender {
            gender.value = uGender.displayValue
        }
        if let uWeight = user.weight {
            weight.value = "\(uWeight) kg"
        }
        if let uHeight = user.height {
            height.value = "\(uHeight) m"
        }
        origin.value = user.origin
        phrase.value = user.phrase
        languages.value = user.languages?.first
        interestedIn.value = user.interestedIn?.first

        profilePic.value = user.profilePic?.urlRequest
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
