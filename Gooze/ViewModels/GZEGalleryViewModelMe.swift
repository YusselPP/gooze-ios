//
//  GZEGalleryViewModelMe.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/1/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZEGalleryViewModelMe: GZEProfileViewModelMe, GZEGalleryViewModel {

    // MARK - GZEGalleryViewModel protocol
    let username = MutableProperty<String?>(nil)

    let thumbnails = [
        MutableProperty<URLRequest?>(nil),
        MutableProperty<URLRequest?>(nil),
        MutableProperty<URLRequest?>(nil),
        MutableProperty<URLRequest?>(nil)
    ]

    let editUserAction = MutableProperty<CocoaAction<GZEEditButton>?>(nil)
    let (segueToUpdatePhoto, segueToUpdatePhotoObs) = Signal<GZEUpdateProfileViewModel, NoError>.pipe()

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

        if let photos = user.photos {
            for (i, photo) in photos.enumerated() {
                if i >= thumbnails.count {
                    break;
                }
                thumbnails[i].value = photo.urlRequest
            }
        }
    }

    private func createEditUserAction() -> Action<Void, Void, NoError> {
        return Action {[weak self] in
            guard let this = self else {return SignalProducer.empty}
            let mutableUser = MutableProperty(this.user)
            mutableUser.signal.observeValues {[weak self] in
                guard let this = self else {return}
                this.user = $0
            }
            this.segueToUpdatePhotoObs.send(
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
