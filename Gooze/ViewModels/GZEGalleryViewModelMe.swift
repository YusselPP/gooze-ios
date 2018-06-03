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


    // MARK - init
    override init(_ user: GZEUser) {
        super.init(user)
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
