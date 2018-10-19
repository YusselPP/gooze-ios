//
//  GZEMapViewModelDate.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/20/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZEMapViewModelDate: NSObject, GZEMapViewModel {

    // MARK - GZEMapViewModel protocol

    let error = MutableProperty<String?>(nil)
    let loading = MutableProperty<Bool>(false)

    let topSliderHidden = MutableProperty<Bool>(true)

    let topLabelText = MutableProperty<String?>("")
    let topLabelHidden = MutableProperty<Bool>(true)

    var bottomButtonAction = MutableProperty<CocoaAction<GZEButton>?>(nil)
    let bottomButtonTitle = MutableProperty<String>("")
    let bottomButtonActionEnabled = MutableProperty<Bool>(true)
    let (dismissSignal, dismissObserver) = Signal<Void, NoError>.pipe()

    let isMapUserInteractionEnabled = MutableProperty<Bool>(true)
    let userAnnotationLocation = MutableProperty<CLLocationCoordinate2D>(CLLocationCoordinate2D())
    let annotationUser: MutableProperty<GZEChatUser>

    var ratingViewModel: GZERatingsViewModel {
        return GZERatingsViewModelRateDate(user: self.annotationUser.value)
    }
    let (ratingViewSignal, ratingViewObserver) = Signal<Void, NoError>.pipe()
    let (segueToHelp, segueToHelpObs) = Signal<GZEHelpViewModel, NoError>.pipe()
    let (exitSignal, exitObserver) = Signal<Void, NoError>.pipe()

    let (dropdownActionSignal, dropdownAction) = Signal<(Int, String), NoError>.pipe()
    let dropdownActions = MutableProperty<[String]>([])

    func viewWillAppear(mapViewContainer: UIView) {
        self.startObservers()
        self.initMap(mapViewContainer: mapViewContainer)
    }

    func viewDidDisappear() {
        self.deinitMap()
        self.disposeObservers()
    }

    // End GZEMapViewModel protocol

    let bottomButtonTitleChat = "vm.map.date.chat".localized().uppercased()
    let bottomButtonTitleStart = "vm.map.date.start".localized().uppercased()
    let bottomButtonTitleEnd = "vm.map.date.end".localized().uppercased()
    let bottomButtonTitleRate = "vm.map.date.rate".localized().uppercased()
    let bottomButtonTitleExit = "vm.map.date.exit".localized().uppercased()
    let topLabelDistance = "vm.map.date.distance".localized()
    let topLabelArrived = "vm.map.date.arrived".localized()
    let topLabelProcess = "vm.map.date.process".localized()
    let topLabelWaitingEnd = "vm.map.date.waitingEnd".localized()
    let topLabelWaitingForYouToEnd = "vm.map.date.waitingForYouToEnd".localized()
    let topLabelCanceled = "vm.map.date.canceled".localized()
    let topLabelEnded = "vm.map.date.ended".localized()
    let cancelDateButtonTitle = "vm.map.date.cancelDateButtonTitle".localized()
    let helpButtonTitle = "vm.map.date.helpButtonTitle".localized()
    let dateAlreadyCanceled = "vm.map.date.alreadyCanceled".localized()
    let cancelDateConfirmTitle = "vm.map.date.cancelDateConfirmTitle".localized()
    let cancelDateConfirmMessage = "vm.map.date.cancelDateConfirmMessage".localized()


    let DateService = GZEDatesService.shared

    var disposableBag = [Disposable?]()

    var dateRequest: MutableProperty<GZEDateRequest>

    var mapView: MKMapView?


    var chatAction: CocoaAction<GZEButton>?
    var startDateAction: CocoaAction<GZEButton>?
    var endDateAction: CocoaAction<GZEButton>?
    var cancelDateAction: CocoaAction<GZEButton>?
    var exitAction: CocoaAction<GZEButton>?
    var rateAction: CocoaAction<GZEButton>?

    // MARK - init
    init(dateRequest: MutableProperty<GZEDateRequest>, mode: GZEChatViewMode) {
        self.dateRequest = dateRequest
        self.dropdownActions.value = [self.helpButtonTitle, self.cancelDateButtonTitle]

        var userId: String
        var username: String
        if mode == .gooze {
            let sender = dateRequest.value.sender
            userId = sender.id
            username = sender.username
            self.annotationUser = MutableProperty(sender)
        } else {
            let recipient = dateRequest.value.recipient
            userId = recipient.id
            username = recipient.username
            self.annotationUser = MutableProperty(recipient)
        }

        super.init()
        log.debug("\(self) init")

        let startDate = self.createStartDateAction()
        let endDate = self.createEndDateAction()
        let cancelDate = self.createCancelDateAction()

        self.topLabelHidden.value = false
        self.chatAction = CocoaAction(self.createChatAction())
        self.rateAction = CocoaAction(self.createRateAction())
        self.startDateAction = CocoaAction(startDate) {[weak self] _ in
            guard let this = self else {return}
            this.loading.value = true
        }
        self.endDateAction = CocoaAction(endDate) {[weak self] _ in
            guard let this = self else {return}
            this.loading.value = true
        }
        self.cancelDateAction = CocoaAction(cancelDate) {[weak self] _ in
            guard let this = self else {return}
            this.loading.value = true
        }
        self.exitAction = CocoaAction(self.createExitAction())


        startDate.events.observeValues {[weak self] event in
            log.debug("startDate event received: \(event)")
            guard let this = self else {return}

            this.loading.value = false

            switch event {
            case .value(let dateRequest):
                this.dateRequest.value = dateRequest
                this.DateService.stopSendingLocationUpdates()
            case .failed(let error):
                this.onError(error)
            default: break
            }
        }

        endDate.events.observeValues {[weak self] event in
            log.debug("endDate event received: \(event)")
            guard let this = self else {return}

            this.loading.value = false

            switch event {
            case .value(let dateRequest):
                this.dateRequest.value = dateRequest
            case .failed(let error):
                this.onError(error)
            default: break
            }
        }

        cancelDate.events.observeValues {[weak self] event in
            log.debug("cancelDate event received: \(event)")
            guard let this = self else {return}

            this.loading.value = false

            switch event {
            case .value(let dateRequest):
                this.dateRequest.value = dateRequest
                this.DateService.stopSendingLocationUpdates()
            case .failed(let error):
                this.onError(error)
            default: break
            }
        }

        GZEUserApiRepository().publicProfile(byId: userId).start{[weak self] event in
            switch event {
            case .value(let user):
                if let location = user.currentLocation?.toCoreLocationCoordinate2D() {
                    self?.userAnnotationLocation.value = location
                }
            default: break
            }
        }

        GZELocationService.shared.lastLocation.producer.skipNil()
            .combineLatest(with: self.dateRequest.producer)
            .take(during: self.reactive.lifetime)
            .take{(_, dateRequest) in
                log.debug("daterequest: \(dateRequest)")
                guard let date = dateRequest.date else {return false}
                return (
                    date.status == .route ||
                    date.status == .starting
                )
            }
            .startWithValues {[weak self] (myLocation, dateRequest) in
                guard let this = self, let date = dateRequest.date else {return}

                let myDistance = myLocation.distance(from: this.dateRequest.value.location.toCLLocation())

                log.debug("last location. myDistance: \(myDistance), mode: \(mode), recipientStarted: \(date.recipientStarted), senderStarted: \(date.senderStarted)")
                if myDistance < 10000 && (mode == .gooze && !date.recipientStarted || mode == .client && !date.senderStarted) {
                    log.debug("last location. action start")
                    this.bottomButtonActionEnabled.value = true
                    this.bottomButtonTitle.value = this.bottomButtonTitleStart
                    this.bottomButtonAction.value = this.startDateAction
                } else {
                    log.debug("last location. action chat")
                    this.bottomButtonActionEnabled.value = true
                    this.bottomButtonTitle.value = this.bottomButtonTitleChat
                    this.bottomButtonAction.value = this.chatAction
                }
        }

        self.userAnnotationLocation.producer.map{CLLocation(latitude: $0.latitude, longitude: $0.longitude)}
            .combineLatest(with: self.dateRequest.producer)
            .take(during: self.reactive.lifetime)
            .take{(_, dateRequest) in
                guard let date = dateRequest.date else {return false}
                return (
                    date.status == .route ||
                    date.status == .starting
                )
            }
            .startWithValues {[weak self] (partnerLocation, dateRequest) in
                guard let this = self, let date = self?.dateRequest.value.date else {return}

                var partnerDistance = partnerLocation.distance(from: this.dateRequest.value.location.toCLLocation())

                if mode == .gooze && date.senderStarted || mode == .client && date.recipientStarted {
                    this.topLabelText.value = String(format: this.topLabelArrived, username)
                    return
                }

                var unit: String = "m."
                if partnerDistance >= 1000 {
                    unit = "km."
                    partnerDistance /= 1000
                }

                this.topLabelText.value = String(format: this.topLabelDistance, username, partnerDistance, unit)
        }

        self.dateRequest.producer
            .map{$0.date}
            .skipNil()
            .startWithValues {[weak self] date in
                guard let this = self else {return}

                log.debug("date.status: \(date.status)")

                switch date.status {
                case .route,
                     .starting:
                    log.debug("dateRequest.producer. mode: \(mode), recipientStarted: \(date.recipientStarted), senderStarted: \(date.senderStarted)")
                    if (mode == .gooze && !date.recipientStarted || mode == .client && !date.senderStarted) {
                        log.debug("startDateAction")
                        this.bottomButtonActionEnabled.value = true
                        this.bottomButtonTitle.value = this.bottomButtonTitleStart
                        this.bottomButtonAction.value = this.startDateAction
                    } else {
                        log.debug("chatAction")
                        this.bottomButtonActionEnabled.value = true
                        this.bottomButtonTitle.value = this.bottomButtonTitleChat
                        this.bottomButtonAction.value = this.chatAction
                    }
                case .progress:
                    this.bottomButtonActionEnabled.value = true
                    this.bottomButtonTitle.value = this.bottomButtonTitleEnd
                    this.bottomButtonAction.value = this.endDateAction
                    this.topLabelText.value = this.topLabelProcess
                case .ended:
                    this.bottomButtonActionEnabled.value = true
                    this.bottomButtonTitle.value = this.bottomButtonTitleRate
                    this.bottomButtonAction.value = this.rateAction
                    this.topLabelText.value = this.topLabelEnded
                    this.ratingViewObserver.send(value: ())
                case .canceled:
                    this.bottomButtonActionEnabled.value = true
                    this.bottomButtonTitle.value = this.bottomButtonTitleExit
                    this.bottomButtonAction.value = this.exitAction
                    this.topLabelText.value = this.topLabelCanceled

                case .ending:
                    if mode == .gooze && date.recipientEnded || mode == .client && date.senderEnded {
                        // if I ended top label must say waiting for other user to end
                        // disable end action
                        this.bottomButtonActionEnabled.value = false
                        this.bottomButtonTitle.value = this.bottomButtonTitleEnd
                        this.bottomButtonAction.value = this.endDateAction
                        this.topLabelText.value = String(format: this.topLabelWaitingEnd, username)
                    } else if mode == .gooze && date.senderEnded || mode == .client && date.recipientEnded {
                        // if the other user ended top label must say, other user ended and is waiting for you to end
                        // end button still enabled
                        this.bottomButtonActionEnabled.value = true
                        this.bottomButtonTitle.value = this.bottomButtonTitleEnd
                        this.bottomButtonAction.value = this.endDateAction
                        this.topLabelText.value = String(format: this.topLabelWaitingForYouToEnd, username)
                    }
                    break
                }
            }

        dropdownActionSignal.observeValues {[weak self] (_, item) in
            guard let this = self else {return}
            if item == this.helpButtonTitle {
                this.segueToHelpObs.send(value: GZEHelpViewModelGooze())
            } else if item == this.cancelDateButtonTitle {
                GZEAlertService.shared.showConfirmDialog(
                    title: this.cancelDateConfirmTitle,
                    message: this.cancelDateConfirmMessage,
                    cancelButtonTitle: "No",
                    destructiveButtonTitle: this.cancelDateButtonTitle,
                    destructiveHandler: { _ in
                        cancelDate.apply().start()
                    }
                )
            }
        }
    }

    func createChatAction() -> Action<Void, Bool, GZEError> {
        return Action(enabledIf: self.bottomButtonActionEnabled) {[weak self] in
            guard let this = self else { log.error("self was disposed"); return SignalProducer(error: .repository(error: .UnexpectedError))}

            this.dismissObserver.send(value: ())

            return SignalProducer.empty
        }
    }

    func createRateAction() -> Action<Void, Bool, GZEError> {
        return Action(enabledIf: self.bottomButtonActionEnabled) {[weak self] in
            guard let this = self else { log.error("self was disposed"); return SignalProducer(error: .repository(error: .UnexpectedError))}

            this.ratingViewObserver.send(value: ())

            return SignalProducer.empty
        }
    }

    func createStartDateAction() -> Action<Void, GZEDateRequest, GZEError> {
        return Action(enabledIf: self.bottomButtonActionEnabled) {[weak self] in
            guard let this = self else { log.error("self was disposed"); return SignalProducer(error: .repository(error: .UnexpectedError))}

            return this.DateService.startDate(this.dateRequest.value)
        }
    }

    func createEndDateAction() -> Action<Void, GZEDateRequest, GZEError> {
        return Action(enabledIf: self.bottomButtonActionEnabled) {[weak self] in
            guard let this = self else { log.error("self was disposed"); return SignalProducer(error: .repository(error: .UnexpectedError))}

            return this.DateService.endDate(this.dateRequest.value)
        }
    }

    func createCancelDateAction() -> Action<Void, GZEDateRequest, GZEError> {
        return Action {[weak self] in
            guard let this = self else { log.error("self was disposed"); return SignalProducer(error: .repository(error: .UnexpectedError))}

            guard this.dateRequest.value.date?.status != .canceled else {
                return SignalProducer(error: .message(text: this.dateAlreadyCanceled, args: []))
            }

            return this.DateService.cancelDate(this.dateRequest.value)
        }
    }

    func createExitAction() -> Action<Void, Bool, GZEError> {
        return Action(enabledIf: self.bottomButtonActionEnabled) {[weak self] in
            guard let this = self else { log.error("self was disposed"); return SignalProducer(error: .repository(error: .UnexpectedError))}

            this.exitObserver.send(value: ())

            return SignalProducer.empty
        }
    }

    func onError(_ error: GZEError) {
        self.error.value = error.localizedDescription
    }

    // MARK: Observers
    func startObservers() {
        self.observeLocationUpdates()
        self.observeDateRequestUpdates()
        self.observeSocketEvents()
    }

    func disposeObservers() {
        log.debug("disposing all observers")
        self.disposableBag.forEach{$0?.dispose()}
        self.disposableBag.removeAll()
    }

    func observeLocationUpdates() {
        log.debug("start observing location updates")
        disposableBag.append(
            DateService.userLastLocation
            .producer
            // .filter{$0.id == user.id}
            .map{$0?.currentLocation?.toCoreLocationCoordinate2D()}
            .skipNil()
            .start {event in
                log.debug("location update received: \(event)")
                switch event {
                case .value(let location):
                    self.userAnnotationLocation.value = location
                default: break
                }
            }
        )
    }

    func observeDateRequestUpdates() {
        log.debug("start observing date request updates")
        disposableBag.append(
            Signal.merge([
                DateService.lastSentRequest.signal,
                DateService.lastReceivedRequest.signal
            ])
                .skipNil()
                .filter{[weak self] in
                    guard let this = self else {return false}
                    return $0.id == this.dateRequest.value.id
                }
                .observeValues {[weak self] dateRequest in
                    guard let this = self else {return}
                    this.dateRequest.value = dateRequest
                }
        )
    }

    func observeSocketEvents() {
        log.debug("start observing socket events")
        disposableBag.append(
            GZEDatesService.shared.dateSocket?
                .socketEventsEmitter
                .signal
                .skipNil()
                .filter { $0 == .authenticated }
                .flatMap(.latest) {[weak self] _ -> SignalProducer<GZEDateRequest, NoError> in
                    guard let this = self else {return SignalProducer.empty}
                    return this.DateService.find(byId: this.dateRequest.value.id)
                        .flatMapError { error in
                            log.error(error)
                            return SignalProducer.empty
                        }
                }
                .observeValues {[weak self] dateRequest in
                    guard let this = self else {return}
                    this.dateRequest.value = dateRequest
                }
        )
    }

    // MARK - MapService

    func initMap(mapViewContainer: UIView) {
        let mapService = GZEMapService.shared
        let mapView = mapService.mapView

        mapView.delegate = mapService
        mapView.showsUserLocation = true

        // Mario: Do not show real location, just update the distance
        //let annotation = GZEUserAnnotation()
        let pointAnnotation = GZEPinAnnotation()

        pointAnnotation.coordinate = dateRequest.value.location.toCoreLocationCoordinate2D()

        //mapView.addAnnotation(annotation)
        mapView.addAnnotation(pointAnnotation)

        mapView.reactive.isUserInteractionEnabled <~ self.isMapUserInteractionEnabled

        //self.annotationUser.producer.startWithValues {user in
        //    annotation.user = user
        //}


//        self.producer.startWithValues{coord in
//            UIView.animate(withDuration: 0.25) {
//                annotation.coordinate = coord
//            }
//        }

        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapViewContainer.addSubview(mapView)
        mapViewContainer.topAnchor.constraint(equalTo: mapView.topAnchor).isActive = true
        mapViewContainer.bottomAnchor.constraint(equalTo: mapView.bottomAnchor).isActive = true
        mapViewContainer.leadingAnchor.constraint(equalTo: mapView.leadingAnchor).isActive = true
        mapViewContainer.trailingAnchor.constraint(equalTo: mapView.trailingAnchor).isActive = true

        self.mapView = mapView
    }

    func deinitMap() {
        GZEMapService.shared.cleanMap()
        self.mapView = nil
    }

    // MARK - deinit
    deinit {
        log.debug("\(self) disposed")
    }
}
