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
        return GZERatingsViewModelRateDate(user: self.annotationUser.value, dateRequestId: self.dateRequest.value.id)
    }
    let (ratingViewSignal, ratingViewObserver) = Signal<Void, NoError>.pipe()

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
    let topLabelDistance = "vm.map.date.distance".localized()
    let topLabelArrived = "vm.map.date.arrived".localized()
    let topLabelProcess = "vm.map.date.process".localized()

    let DateService = GZEDatesService.shared

    var disposableBag = [Disposable?]()

    var dateRequest: MutableProperty<GZEDateRequest>

    var mapView: MKMapView?


    var chatAction: CocoaAction<GZEButton>?
    var startDateAction: CocoaAction<GZEButton>?
    var endDateAction: CocoaAction<GZEButton>?


    // MARK - init
    init(dateRequest: GZEDateRequest, mode: GZEChatViewMode) {
        self.dateRequest = MutableProperty(dateRequest)

        var userId: String
        var username: String
        if mode == .gooze {
            userId = dateRequest.sender.id
            username = dateRequest.sender.username
            self.annotationUser = MutableProperty(dateRequest.sender)
        } else {
            userId = dateRequest.recipient.id
            username = dateRequest.recipient.username
            self.annotationUser = MutableProperty(dateRequest.recipient)
        }

        super.init()
        log.debug("\(self) init")

        let startDate = self.createStartDateAction()
        let endDate = self.createEndDateAction()

        self.topLabelHidden.value = false
        self.chatAction = CocoaAction(self.createChatAction())
        self.startDateAction = CocoaAction(startDate) {[weak self] _ in
            guard let this = self else {return}
            this.loading.value = true
        }
        self.endDateAction = CocoaAction(endDate) {[weak self] _ in
            guard let this = self else {return}
            this.loading.value = true
        }


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
                this.ratingViewObserver.send(value: ())
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

        let producers: [SignalProducer<CLLocation, NoError>] = [
            GZELocationService.shared.lastLocation.producer.skipNil().throttle(3, on: QueueScheduler.main),
            self.userAnnotationLocation.producer.map{CLLocation(latitude: $0.latitude, longitude: $0.longitude)}
        ]

        SignalProducer.combineLatest(producers)
            .take(during: self.reactive.lifetime)
            .take{[weak self] _ in
                guard let this = self else {return false}
                return this.dateRequest.value.date?.status == .route
            }
            .startWithValues {[weak self] locations in
                guard let this = self else {return}

                let myLocation = locations[0]
                let partnerLocation = locations[1]

                let myDistance = myLocation.distance(from: this.dateRequest.value.location.toCLLocation())
                var partnerDistance = partnerLocation.distance(from: this.dateRequest.value.location.toCLLocation())


                if myDistance < 50 && partnerDistance < 50 {
                    this.topLabelText.value = String(format: this.topLabelArrived, username)
                    this.bottomButtonTitle.value = this.bottomButtonTitleStart
                    this.bottomButtonAction.value = this.startDateAction
                    return
                }

                this.bottomButtonTitle.value = this.bottomButtonTitleChat
                this.bottomButtonAction.value = this.chatAction

                if partnerDistance < 50 {
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
            .map{$0.date?.status}
            .skipNil()
            .startWithValues {[weak self] status in
                guard let this = self else {return}

                switch status {
                case .route: break
                case .progress:
                    this.bottomButtonTitle.value = this.bottomButtonTitleEnd
                    this.bottomButtonAction.value = this.endDateAction
                    this.topLabelText.value = this.topLabelProcess
                case .ended:
                // TODO: send to rate user view
                    break
                default: this.dismissObserver.send(value: ())
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

        let annotation = GZEUserAnnotation()
        let pointAnnotation = GZEPinAnnotation()

        pointAnnotation.coordinate = dateRequest.value.location.toCoreLocationCoordinate2D()

        mapView.addAnnotation(annotation)
        mapView.addAnnotation(pointAnnotation)

        mapView.reactive.isUserInteractionEnabled <~ self.isMapUserInteractionEnabled

        self.annotationUser.producer.startWithValues {user in
            annotation.user = user
        }

        self.userAnnotationLocation.producer.startWithValues{coord in
            UIView.animate(withDuration: 0.25) {
                annotation.coordinate = coord
            }
        }

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
