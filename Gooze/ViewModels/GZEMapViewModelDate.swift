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

    let topSliderHidden = MutableProperty<Bool>(true)

    let topLabelText = MutableProperty<String?>("")
    let topLabelHidden = MutableProperty<Bool>(true)

    var bottomButtonAction: CocoaAction<GZEButton>?
    let bottomButtonTitle = MutableProperty<String>("")
    let bottomButtonActionEnabled = MutableProperty<Bool>(true)
    let (dismissSignal, dismissObserver) = Signal<Bool, NoError>.pipe()

    let isMapUserInteractionEnabled = MutableProperty<Bool>(true)
    let userAnnotationLocation = MutableProperty<CLLocationCoordinate2D>(CLLocationCoordinate2D())
    let annotationUser = MutableProperty<GZEChatUser?>(nil)

    func viewWillAppear(mapViewContainer: UIView) {
        self.observeLocationUpdates()
        self.initMap(mapViewContainer: mapViewContainer)
    }

    func viewDidDisappear() {
        self.deinitMap()
        self.disposeObservers()
    }

    // End GZEMapViewModel protocol

    let bottomButtonTitleChat = "vm.map.date.chat".localized().uppercased()
    let topLabelDistance = "vm.map.date.distance".localized()
    let topLabelArrived = "vm.map.date.arrived".localized()

    var disposableBag = [Disposable?]()

    var dateRequest: GZEDateRequest

    var mapView: MKMapView?

    // MARK - init
    init(dateRequest: GZEDateRequest, mode: GZEChatViewMode) {
        self.dateRequest = dateRequest
        super.init()
        log.debug("\(self) init")

        self.topLabelHidden.value = false

        var userId: String
        var username: String
        if mode == .gooze {
            userId = dateRequest.sender.id
            username = dateRequest.sender.username
            self.annotationUser.value = dateRequest.sender
        } else {
            userId = dateRequest.recipient.id
            username = dateRequest.recipient.username
            self.annotationUser.value = dateRequest.recipient
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

        self.userAnnotationLocation.producer.take(during: self.reactive.lifetime)
            .startWithValues {[weak self] location in
                guard let this = self else {return}

                var unit: String = "m."
                var distance = (
                    CLLocation(latitude: location.latitude, longitude: location.longitude)
                        .distance(from: this.dateRequest.location.toCLLocation())
                )

                if distance < 50 {
                    this.topLabelText.value = String(format: this.topLabelArrived, username)
                    return
                }

                if distance >= 1000 {
                    unit = "km."
                    distance /= 1000
                }

                this.topLabelText.value = String(format: this.topLabelDistance, username, distance, unit)
            }

        self.bottomButtonTitle.value = self.bottomButtonTitleChat
        self.bottomButtonAction = CocoaAction(self.createBottomButtonAction())
    }

    func createBottomButtonAction() -> Action<Void, Bool, GZEError> {
        return Action.init(enabledIf: self.bottomButtonActionEnabled) {[weak self] in
            guard let this = self else { log.error("self was disposed"); return SignalProducer(error: .repository(error: .UnexpectedError))}

            this.dismissObserver.send(value: true)

            return SignalProducer.empty
        }
    }

    func observeLocationUpdates() {
        log.debug("start observing location updates")
        disposableBag.append(
            GZEDatesService.shared.userLastLocation
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

    func disposeObservers() {
        log.debug("disposing all observers")
        self.disposableBag.forEach{$0?.dispose()}
        self.disposableBag.removeAll()
    }

    // MARK - MapService

    func initMap(mapViewContainer: UIView) {
        let mapService = GZEMapService.shared
        let mapView = mapService.mapView

        mapView.delegate = mapService
        mapView.showsUserLocation = true

        let annotation = GZEUserAnnotation()
        let pointAnnotation = GZEPinAnnotation()

        pointAnnotation.coordinate = dateRequest.location.toCoreLocationCoordinate2D()

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
