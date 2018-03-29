//
//  GZEGalleryViewModelReadOnly.swift
//  Gooze
//
//  Created by Yussel on 3/6/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift

class GZEGalleryViewModelReadOnly: NSObject, GZEGalleryViewModel {

    // MARK - GZEGalleryViewModel protocol
    let mode = MutableProperty<GZEProfileMode>(.contact)
    let error = MutableProperty<String?>(nil)

    let contactButtonTitle = "vm.profile.contactTitle".localized().uppercased()
    let acceptRequestButtonTitle = "vm.profile.acceptRequestTitle".localized().uppercased()
    
    let username = MutableProperty<String?>(nil)

    let thumbnails = [
        MutableProperty<URLRequest?>(nil),
        MutableProperty<URLRequest?>(nil),
        MutableProperty<URLRequest?>(nil),
        MutableProperty<URLRequest?>(nil)
    ]

    func contact() {
        guard let userId = user.id else {
            log.error("User in profile doesn't have an id")
            error.value = GZERepositoryError.UnexpectedError.localizedDescription
            return
        }
        GZEDatesService.shared.requestDate(to: userId)
    }

    func acceptRequest() {
        // Open chat
    }

    let user: GZEUser

    // MARK - init
    init(user: GZEUser) {
        self.user = user
        super.init()
        log.debug("\(self) init")

        populate(user)
    }

    private func populate(_ user: GZEUser) {
        username.value = user.username?.uppercased()

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
