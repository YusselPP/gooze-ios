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

class GZESignUpViewModel: NSObject, iCarouselDataSource {

    let userRepository: GZEUserRepositoryProtocol
    let user: GZEUser

    // basic sign up
    let username = MutableProperty<String?>("")
    let email = MutableProperty<String?>("")
    let password = MutableProperty<String?>("")

    // additional data
    let birthday = MutableProperty<String?>("")
    let gender = MutableProperty<String?>("")
    let weight = MutableProperty<String?>("")
    let height = MutableProperty<String?>("")
    let origin = MutableProperty<String?>("")
    let phrase = MutableProperty<String?>("")
    let languages = MutableProperty<String?>("")
    let interestedIn = MutableProperty<String?>("")

    var photos = [MutableProperty<UIImage?>]()


    enum validationRule {
        case username

        var stringRules: ValidationRuleSet<String>? {
            switch self {
            case .username:
                return GZEUser.Validation.username.stringRule()
            default:
                return nil
            }
        }
    }


    var saveAction: Action<Void, GZEFile, GZEError> {
        if let saveAction = _saveAction {
            return saveAction
        }
        _saveAction = createSaveAction()
        return _saveAction!
    }
    private var _saveAction: Action<Void, GZEFile, GZEError>?


    init(_ userRepository: GZEUserRepositoryProtocol) {
        self.userRepository = userRepository
        self.user = GZEUser()
        super.init()

        log.debug("\(self) init")
    }

    private func createSaveAction() -> Action<Void, GZEFile, GZEError> {
        log.debug("Creating save action")
        return Action<Void, GZEFile, GZEError>{[weak self] in
            guard let strongSelf = self else { return SignalProducer.empty }
            strongSelf.fillUser()
            // return strongSelf.userRepository.create(strongSelf.user)
            return strongSelf.userRepository.signUp(strongSelf.user)
        }
    }

    private func fillUser() {
        log.debug("fill user attributes")
        user.username = username.value
        user.email = email.value
        user.password = password.value

        if let birthday = birthday.value {
            user.birthday = DateFormatter().date(from: birthday)
        }
        if let gender = gender.value {
            user.gender = GZEUser.Gender(rawValue: gender)
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
        user.photos = photos.map { GZEUser.Photo(image: $0.value) }
        log.debug(user)
    }

    // MARK: iCarousel data source protocol

    func numberOfItems(in carousel: iCarousel) -> Int {
        return photos.count
    }

    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {

        var itemView: UIImageView

        //reuse view if available, otherwise create a new view
        if let view = view as? UIImageView {
            itemView = view
        } else {
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 150))
            itemView.image = photos[index].value
            itemView.contentMode = .scaleAspectFit
        }

        log.debug("item showed \(index)")
        return itemView
    }

//    func numberOfPlaceholders(in carousel: iCarousel) -> Int {
//        return 5 - photos.count
//    }
//
//    func carousel(_ carousel: iCarousel, placeholderViewAt index: Int, reusing view: UIView?) -> UIView {
//        var itemView: UIImageView
//        //reuse view if available, otherwise create a new view
//        if let view = view as? UIImageView {
//            itemView = view
//        } else {
//            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
//            itemView.image = #imageLiteral(resourceName: "default-profile-pic")
//            itemView.contentMode = .scaleToFill
//        }
//
//        log.debug("item showed \(index)")
//        return itemView
//    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
