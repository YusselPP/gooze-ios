//
//  GZERatingsViewModelRateDate.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/15/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZERatingsViewModelRateDate: GZEProfileViewModelRateDate, GZERatingsViewModel {
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

    let imagesRatingIsEditable = MutableProperty<Bool>(true)
    let complianceRatingIsEditable = MutableProperty<Bool>(true)
    let dateQualityRatingIsEditable = MutableProperty<Bool>(true)
    let dateRatingIsEditable = MutableProperty<Bool>(true)
    let goozeRatingIsEditable = MutableProperty<Bool>(true)

    // END GZERatingsViewModel protocol

    // MARK: - private properties
    let phraseLabelComments = "vm.rate.date.comments".localized().uppercased()

    let userRepository: GZEUserRepositoryProtocol = GZEUserApiRepository()

    let rateActionEnalbed = MutableProperty<Bool>(true)

    let user: MutableProperty<GZEChatUser>

    // MARK - init
    init(user: GZEChatUser, dateRequestId: String?) {
        self.user = MutableProperty(user)
        super.init()
        log.debug("\(self) init")

        self.populate(user)
        self.initProperties()
    }

    private func populate(_ user: GZEChatUser) {
        username.value = user.username.uppercased()

        profilePic.value = user.profilePic?.urlRequest
    }

    private func initProperties(){
        phrase.value = phraseLabelComments

        imagesRatingDesc.value = GZEUser.Validation.imagesRating.fieldName
        complianceRatingDesc.value = GZEUser.Validation.complianceRating.fieldName
        dateQualityRatingDesc.value = GZEUser.Validation.dateQualityRating.fieldName
        dateRatingDesc.value = GZEUser.Validation.dateRating.fieldName
        goozeRatingDesc.value = GZEUser.Validation.goozeRating.fieldName

        imagesRating.value = 5
        complianceRating.value = 5
        dateQualityRating.value = 5
        dateRating.value = 5
        goozeRating.value = 5

        overallRating <~ SignalProducer.combineLatest([
            imagesRating.producer.skipNil(),
            complianceRating.producer.skipNil(),
            dateQualityRating.producer.skipNil(),
            dateRating.producer.skipNil(),
            goozeRating.producer.skipNil()
        ])
            .map{$0.reduce(0, +) / Float($0.count)}


        let rateAction = self.createRateAction()
        rateAction.events.observeValues {[weak self] in
            self?.onRateActionEvent($0)
        }

        self.bottomButtonAction = CocoaAction(rateAction) {[weak self] _ in
            self?.loading.value = true
        }
    }

    private func createRateAction() -> Action<Void, Bool, GZEError> {
        return Action(enabledIf: self.rateActionEnalbed) {[weak self] in
            guard let this = self else {return SignalProducer(error: .repository(error: .UnexpectedError))}

            guard
                let imagesRating = this.imagesRating.value,
                let complianceRating = this.complianceRating.value,
                let dateQualityRating = this.dateQualityRating.value,
                let dateRating = this.dateRating.value,
                let goozeRating = this.goozeRating.value
            else {
                log.error("ratings are required, found nil")
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }

            let ratings = GZERatings(
                imagesRating: imagesRating,
                complianceRating: complianceRating,
                dateQualityRating: dateQualityRating,
                dateRating: dateRating,
                goozeRating: goozeRating
            )

            return this.userRepository.add(ratings: ratings, userId: this.user.value.id)
        }
    }

    private func onRateActionEvent(_ event: Event<Bool, GZEError>) {
        self.loading.value = false

        switch event {
        case .value:
        break // TODO: dispose to search view
        case .failed(let error):
            onError(error)
        default:
            break
        }
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
