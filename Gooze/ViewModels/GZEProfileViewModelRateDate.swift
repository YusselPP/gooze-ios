//
//  GZEProfileViewModelRateDate.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/15/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZEProfileViewModelRateDate: GZEProfileViewModel {

    // MARK: - GZEProfileViewModel protocol
    var mode = GZEProfileMode.contact
    var dateRequest = MutableProperty<GZEDateRequest?>(nil)

    var bottomButtonAction: CocoaAction<GZEButton>?

    let loading = MutableProperty<Bool>(false)
    let error = MutableProperty<String?>(nil)

    let actionButtonTitle = MutableProperty<String>("vm.profile.rate.date.rate".localized())

    weak var controller: UIViewController?

    func startObservers() {
    }

    func stopObservers() {
    }
    //END GZEProfileViewModel protocol

    func onError(_ error: GZEError) {
        self.error.value = error.localizedDescription
    }

    // MARK: - deinit
    deinit {
        log.debug("\(self) disposed")
    }
}
