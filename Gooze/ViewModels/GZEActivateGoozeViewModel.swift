//
//  GZEActivateGoozeViewModel.swift
//  Gooze
//
//  Created by Yussel on 11/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import CoreLocation

class GZEActivateGoozeViewModel {

    let userRepository: GZEUserRepositoryProtocol

    let currentLocation = MutableProperty<CLLocationCoordinate2D>(CLLocationCoordinate2D())
    let activeTime = MutableProperty<Float>(1)
    let radiusDistance = MutableProperty<Float>(1)
    let searchLimit = MutableProperty<Int>(5)

    let activateButtonTitle = "vm.activate.activateButtonTitle".localized()
    let searchButtonTitle = "vm.activate.searchButtonTitle".localized()
    let allResultsButtonTitle = "vm.activate.allResultsButtonTitle".localized()

    var activateGoozeAction: Action<Void, GZEUser, GZEError> {
        if let activateGoozeAction = _activateGoozeAction {
            return activateGoozeAction
        }
        _activateGoozeAction = createActivateGoozeAction()
        return _activateGoozeAction!
    }
    private var _activateGoozeAction: Action<Void, GZEUser, GZEError>?

    var searchGoozeAction: Action<Void, [GZEUser], GZEError> {
        if let searchGoozeAction = _searchGoozeAction {
            return searchGoozeAction
        }
        _searchGoozeAction = createSearchGoozeAction()
        return _searchGoozeAction!
    }
    private var _searchGoozeAction: Action<Void, [GZEUser], GZEError>?


    init(_ userRepository: GZEUserRepositoryProtocol) {
        self.userRepository = userRepository

        log.debug("\(self) init")
    }

    private func createActivateGoozeAction() -> Action<Void, GZEUser, GZEError> {
        log.debug("Creating activate gooze action")
        return Action<Void, GZEUser, GZEError>{[weak self] in
            guard let this = self else { return SignalProducer.empty }


            guard let userId = GZEApi.instance.accessToken?.userId else {
                return SignalProducer(error: GZEError.repository(error: .AuthRequired))
            }

            let user = GZEUser()
            user.id = userId
            user.currentLocation = GZEUser.GeoPoint(CLCoord: this.currentLocation.value)
            user.activeUntil = Date(timeIntervalSinceNow: Double(this.activeTime.value * 60 * 60))

            log.debug(user.toJSON() as Any)

            return this.userRepository.update(user)
        }
    }

    private func createSearchGoozeAction() -> Action<Void, [GZEUser], GZEError> {
        log.debug("Creating search gooze action")
        return Action<Void, [GZEUser], GZEError>{[weak self] in
            guard let this = self else { return SignalProducer.empty }

            return this.userRepository.find(byLocation: GZEUser.GeoPoint(CLCoord: this.currentLocation.value), maxDistance: this.radiusDistance.value, limit: this.searchLimit.value)
        }
    }
    
    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
