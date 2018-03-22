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
    let sliderValue = MutableProperty<Float>(1)
    let searchLimit = MutableProperty<Int>(5)

    var userResults = MutableProperty<[GZEUser]>([])

    let searchViewTitle = "vm.search.viewTitle".localized()
    let zeroResultsMessage = "vm.search.zeroResultsMessage".localized()
    let searchingButtonTitle = "vm.search.searchingButtonTitle".localized()

    let activateButtonTitle = "vm.activate.activateButtonTitle".localized()
    let deactivateButtonTitle = "vm.activate.deactivateButtonTitle".localized()
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

    var findGoozeAction: Action<String, GZEUser, GZEError> {
        if let findGoozeAction = _findGoozeAction {
            return findGoozeAction
        }
        _findGoozeAction = createFindGoozeAction()
        return _findGoozeAction!
    }
    private var _findGoozeAction: Action<String, GZEUser, GZEError>?

    var deactivateGoozeAction: Action<Void, GZEUser, GZEError>!


    init(_ userRepository: GZEUserRepositoryProtocol) {
        self.userRepository = userRepository

        log.debug("\(self) init")

        deactivateGoozeAction = Action { [weak self] in
            guard let this = self else {
                log.error("self disposed")
                return SignalProducer(error: GZEError.repository(error: .UnexpectedError))
            }
            return this.deactivateGoozeHandler()
        }
    }

    private func createActivateGoozeAction() -> Action<Void, GZEUser, GZEError> {
        log.debug("Creating activate gooze action")
        return Action<Void, GZEUser, GZEError>{[weak self] in
            guard let this = self else {
                log.error("self disposed")
                return SignalProducer(error: GZEError.repository(error: .UnexpectedError))
            }


            guard let userId = GZEApi.instance.accessToken?.userId else {
                return SignalProducer(error: GZEError.repository(error: .AuthRequired))
            }

            let user = GZEUser()
            user.id = userId
            user.currentLocation = GZEUser.GeoPoint(CLCoord: this.currentLocation.value)
            user.activeUntil = Date(timeIntervalSinceNow: Double(this.sliderValue.value * 60 * 60))

            log.debug(user.toJSON() as Any)

            return this.userRepository.update(user)
        }
    }

    private func createSearchGoozeAction() -> Action<Void, [GZEUser], GZEError> {
        log.debug("Creating search gooze action")
        return Action<Void, [GZEUser], GZEError>{[weak self] in
            guard let this = self else {
                log.error("self disposed")
                return SignalProducer(error: GZEError.repository(error: .UnexpectedError))
            }

            return this.userRepository.find(byLocation: GZEUser.GeoPoint(CLCoord: this.currentLocation.value), maxDistance: this.sliderValue.value, limit: this.searchLimit.value)
        }
    }

    private func createFindGoozeAction() -> Action<String, GZEUser, GZEError> {
        log.debug("Creating find gooze action")
        return Action<String, GZEUser, GZEError>{ [weak self] userId in
            guard let this = self else {
                log.error("self disposed")
                return SignalProducer(error: GZEError.repository(error: .UnexpectedError))
            }

            log.debug("finding user[id=\(userId)]")

            return this.userRepository.publicProfile(byId: userId)
        }
    }

    private func deactivateGoozeHandler() -> SignalProducer<GZEUser, GZEError> {
        guard let userId = GZEApi.instance.accessToken?.userId else {
            return SignalProducer(error: GZEError.repository(error: .AuthRequired))
        }

        let user = GZEUser()
        user.id = userId
        user.activeUntil = Date().addingTimeInterval(-1000)

        log.debug(user.toJSON() as Any)

        return userRepository.update(user)
    }
    
    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
