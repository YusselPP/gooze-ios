//
//  GZEProfileViewModel.swift
//  Gooze
//
//  Created by Yussel on 2/22/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift

class GZEProfileViewModel: NSObject {

    // basic data
    let username = MutableProperty<String?>(nil)

    // additional data
    let age = MutableProperty<String?>(nil)
    let gender = MutableProperty<String?>(nil)
    let weight = MutableProperty<String?>(nil)
    let height = MutableProperty<String?>(nil)
    let origin = MutableProperty<String?>(nil)
    let phrase = MutableProperty<String?>(nil)
    let languages = MutableProperty<String?>(nil)
    let interestedIn = MutableProperty<String?>(nil)

    // TODO: Implement ocupation in user model
    let ocupation = MutableProperty<String?>(nil)

    let profilePic = MutableProperty<URLRequest?>(nil)

    var photos = [MutableProperty<URLRequest?>]()

    let mainImage = MutableProperty<UIImage?>(nil)


    init(user: GZEUser) {
        super.init()
        log.debug("\(self) init")

        populate(user)
    }

    private func populate(_ user: GZEUser) {
        username.value = user.username

        age.value = user.birthday.map{ "\(GZEDateHelper.years(from: $0, to: Date()))" }
        if let uGender = user.gender {
            gender.value = uGender.rawValue
        }
        if let uWeight = user.weight {
            weight.value = "\(uWeight)"
        }
        if let uHeight = user.height {
            height.value = "\(uHeight)"
        }
        origin.value = user.origin
        phrase.value = user.phrase
        languages.value = user.languages?.first
        interestedIn.value = user.interestedIn?.first

        profilePic.value = user.profilePic?.urlRequest

        if let uPhotos = user.photos {
            photos = uPhotos.map { MutableProperty($0.urlRequest) }
        }
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
