//
//  GZEProfileViewModelMe.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/1/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import enum Result.NoError

class GZEProfileViewModelMe: GZEProfileViewModel {

    // MARK: - GZEProfileViewModel protocol
    var mode = GZEProfileMode.contact
    let dateRequest = MutableProperty<GZEDateRequest?>(nil)
    var bottomButtonAction: CocoaAction<GZEButton>?
    let loading = MutableProperty<Bool>(false)
    let error = MutableProperty<String?>(nil)
    let actionButtonIsHidden = MutableProperty<Bool>(true)
    let actionButtonTitle = MutableProperty<String>("")
    var controller: UIViewController?
    func startObservers() {}
    func stopObservers() {}
    // END GZEProfileViewModel protocol

    let user: GZEUser

    // MARK - init
    init(_ user: GZEUser) {
        self.user = user
        log.debug("\(self) init")
    }

    deinit {
        log.debug("\(self) init")
    }
}
