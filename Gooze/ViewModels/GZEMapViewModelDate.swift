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
    let bottomButtonActionEnabled = MutableProperty<Bool>(false)
    let (dismissSignal, dismissObserver) = Signal<Bool, NoError>.pipe()

    let isMapUserInteractionEnabled = MutableProperty<Bool>(true)
    let userAnnotationLocation = MutableProperty<CLLocationCoordinate2D>(CLLocationCoordinate2D())
    let annotationUser = MutableProperty<GZEChatUser?>(nil)

    func viewWillAppear() {
        self.observeLocationUpdates()
    }

    func viewDidDisappear() {
        self.disposeObservers()
    }

    // End GZEMapViewModel protocol

    var disposableBag = [Disposable?]()

    var dateRequest: GZEDateRequest

    // MARK - init
    init(dateRequest: GZEDateRequest, mode: GZEChatViewMode) {
        self.dateRequest = dateRequest
        super.init()
        log.debug("\(self) init")

        if mode == .gooze {
            self.annotationUser.value = dateRequest.sender
        } else {
            self.annotationUser.value = dateRequest.recipient
        }

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

    // MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        log.debug("requesting annotation view")
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }

        // if annotation.isKind(of: GZEUserAnnotation.self) {
        var userAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "GZEUserAnnotationView")

        if userAnnotationView == nil {
            userAnnotationView = GZEUserAnnotationView(annotation: annotation, reuseIdentifier: "GZEUserAnnotationView")

            let screenSize = UIScreen.main.bounds
            userAnnotationView?.widthAnchor.constraint(equalToConstant: min(min(screenSize.height, screenSize.width) / 3, 120)).isActive = true
        } else {
            userAnnotationView!.annotation = annotation
        }

        return userAnnotationView
    }

    // MARK - deinit
    deinit {
        log.debug("\(self) disposed")
    }
}
