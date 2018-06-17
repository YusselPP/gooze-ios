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
import SwiftOverlays

class GZEProfileViewModelMe: GZEProfileViewModel {

    // MARK: - GZEProfileViewModel protocol
    var mode = GZEProfileMode.contact
    let dateRequest = MutableProperty<GZEDateRequest?>(nil)
    var bottomButtonAction: CocoaAction<GZEButton>?
    let loading = MutableProperty<Bool>(false)
    let error = MutableProperty<String?>(nil)
    let actionButtonIsHidden = MutableProperty<Bool>(true)
    let actionButtonTitle = MutableProperty<String>("")
    weak var controller: UIViewController?
    func startObservers() {}
    func stopObservers() {}

    let (didLoad, didLoadObs) = Signal<Void, NoError>.pipe()
    // END GZEProfileViewModel protocol

    var user: GZEUser
    let userRepository: GZEUserRepositoryProtocol = GZEUserApiRepository()

    // MARK - init
    init(_ user: GZEUser) {
        self.user = user
        log.debug("\(self) init")

        self.didLoad.signal.observeValues {[weak self] in
            guard let this = self else {return}
            this.getUpdatedProfile()
        }
    }

    func getUpdatedProfile() {
        guard let userId = GZEAuthService.shared.authUser?.id else {
            log.error("nil authUser found")
            return
        }

        var overlay: UIView?
        if let view = self.controller?.view {
            overlay = SwiftOverlays.showCenteredWaitOverlay(view)
        }

        userRepository.find(byId: userId).start() {[weak self] event in
            log.debug("event received: \(event)")
            guard let this = self else {return}

            if let overlay = overlay {
                overlay.removeFromSuperview()
            }

            switch event {
            case .value(let user):
                this.user = user
            case .failed(let error):
                log.error(error.localizedDescription)
            default: break
            }
        }
    }

    deinit {
        log.debug("\(self) init")
    }
}
