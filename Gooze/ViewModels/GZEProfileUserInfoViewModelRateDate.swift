//
//  GZEProfileUserInfoViewModelRateDate.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/21/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZEProfileUserInfoViewModelRateDate: GZEProfileViewModelRateDate, GZEProfileUserInfoViewModel {

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

    let (dismissSignal, dismissObserver) = Signal<Void, NoError>.pipe()
    var editUserAction = MutableProperty<CocoaAction<GZEEditButton>?>(nil)
    var editUserButtonIsHidden = MutableProperty<Bool>(true)
    var (segueToUpdateProfile, _) = Signal<GZEUpdateProfileViewModel?, NoError>.pipe()


    // MARK: - Private properties
    let rateCommentRepository: GZERateCommentRepositoryProtocol = GZERateCommentApiRepository()

    let comments = MutableProperty<[GZERateComment]>([])
    let selectedComment = MutableProperty<GZERateComment?>(nil)

    let ratings: MutableProperty<GZERatings>

    private(set) lazy var availableSlots = {
        return [
            self.age,
            self.gender,
            self.height,
            self.weight,
            self.origin,
            self.languages,
            self.interestedIn
        ]
    }()

    private(set) lazy var actions = {
        return [
            self.ageAction,
            self.genderAction,
            self.heightAction,
            self.weightAction,
            self.originAction,
            self.languagesAction,
            self.interestedInAction
        ]
    }()

    lazy var selectCommentAction = {
        return Action<Int, Void, NoError> {[weak self] index in
            guard
                let this = self,
                index < this.comments.value.count
            else {return SignalProducer.empty}

            this.selectedComment.value = this.comments.value[index]
            return SignalProducer.empty
        }
    }()

    lazy var acceptCommentAction = {
        return Action<Void, Void, NoError> {[weak self] in
            guard
                let this = self
            else {return SignalProducer.empty}

            this.ratings.value.comment = this.selectedComment.value

            if let ratingsJson = this.ratings.value.toJSON(),
                let ratings = GZERatings(json: ratingsJson) {
                this.ratings.value = ratings
            } else {
                log.error("Unable to parse ratings")
            }
            this.dismissObserver.send(value: ())

            return SignalProducer.empty
        }
    }()



    // MARK - init
    init(user: GZEChatUser, ratings: MutableProperty<GZERatings>) {
        self.ratings = ratings
        super.init()
        log.debug("\(self) init")

        self.phrase <~ self.selectedComment.map{$0?.localizedText()}
        self.comments.producer.startWithValues{[weak self] comments in
            self?.populate(with: comments)
        }

        self.actionButtonTitle.value = "profile.rate.date.accept".localized()
        self.bottomButtonAction = CocoaAction(self.acceptCommentAction)

        requestComments()
        populate(user)
        createActions()
    }

    private func requestComments() {
        loading.value = true
        rateCommentRepository.findAll().start{[weak self] event in
            guard let this = self else {
                log.error("self was disposed")
                return
            }

            this.loading.value = false

            switch event {
            case .value(let comments):
                this.comments.value = comments
            case .failed(let error):
                this.onError(error)
            default: break
            }
        }
    }

    private func populate(_ user: GZEChatUser) {
        username.value = user.username.uppercased()
        profilePic.value = user.profilePic?.urlRequest
    }

    private func populate(with comments: [GZERateComment]) {
        let availableSlotsCount = availableSlots.count

        self.selectedComment.value = nil

        for (index, comment) in comments.enumerated() {

            if index >= availableSlotsCount {
                break
            }

            availableSlots[index].value = comment.localizedText()

            if comment.id == self.ratings.value.comment?.id {
                self.selectedComment.value = comment
            }
        }
    }

    private func createActions() {
        for (index, action) in self.actions.enumerated() {
            action.value = CocoaAction(self.selectCommentAction){_ in index}
        }
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
