//
//  GZEGalleryViewModelReadOnly.swift
//  Gooze
//
//  Created by Yussel on 3/6/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZEGalleryViewModelReadOnly: GZEProfileViewModelReadOnly, GZEGalleryViewModel {

    // MARK - GZEGalleryViewModel protocol
    let username = MutableProperty<String?>(nil)

    let thumbnails = [
        MutableProperty<URLRequest?>(nil),
        MutableProperty<URLRequest?>(nil),
        MutableProperty<URLRequest?>(nil),
        MutableProperty<URLRequest?>(nil)
    ]

    var editUserAction = MutableProperty<CocoaAction<GZEEditButton>?>(nil)
    var editUserButtonIsHidden = MutableProperty<Bool>(true)
    var (segueToUpdatePhoto, _) = Signal<GZEUpdateProfileViewModel, NoError>.pipe()

    
    // MARK - init
    override init(user: GZEUser, dateRequest: MutableProperty<GZEDateRequest?>) {
        super.init(user: user, dateRequest: dateRequest)
        log.debug("\(self) init")

        populate(user)
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

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
