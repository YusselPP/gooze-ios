//
//  GZEMapService.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/22/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import MapKit
import ReactiveSwift

class GZEMapService: NSObject, MKMapViewDelegate {

    static let shared = GZEMapService()

    let mapView = MKMapView()
    let centerCoordinate = MutableProperty<CLLocationCoordinate2D?>(nil)
    let userLocation = MutableProperty<CLLocationCoordinate2D?>(nil)

    var disposables = [Disposable?]()


    override init() {
        super.init()
        self.mapView.userLocation.title = nil
        self.mapView.delegate = self
        if CLLocationCoordinate2DIsValid(self.mapView.centerCoordinate) {
            self.centerCoordinate.value = self.mapView.centerCoordinate
        }
        if CLLocationCoordinate2DIsValid(self.mapView.userLocation.coordinate) {
            self.userLocation.value = self.mapView.userLocation.coordinate
        }
    }

    func cleanMap() {
        self.disposables.forEach{$0?.dispose()}
        self.disposables.removeAll()

        self.mapView.removeFromSuperview()
        self.mapView.delegate = nil
        self.mapView.showsUserLocation = false
        self.mapView.removeAnnotations(self.mapView.annotations)
    }

    // MARK: - Map Delegate

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        log.debug("Map region changed. Center=[\(mapView.centerCoordinate)]")
        if CLLocationCoordinate2DIsValid(mapView.centerCoordinate) {
            self.centerCoordinate.value = mapView.centerCoordinate
        }
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        log.debug("User location updated: \(userLocation.coordinate)")
        if CLLocationCoordinate2DIsValid(userLocation.coordinate) {
            self.userLocation.value = userLocation.coordinate
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        log.debug("requesting annotation view")
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }

        if let userAnnotation = annotation as? GZEUserAnnotation {
            var userAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "GZEUserAnnotationView") as? GZEUserAnnotationView

            if userAnnotationView == nil {
                userAnnotationView = GZEUserAnnotationView(annotation: userAnnotation, reuseIdentifier: "GZEUserAnnotationView")
                userAnnotationView?.layer.zPosition = -1

                let screenSize = UIScreen.main.bounds
                userAnnotationView?.widthAnchor.constraint(equalToConstant: min(min(screenSize.height, screenSize.width) / 3, 120)).isActive = true
            } else {
                userAnnotationView?.annotation = userAnnotation
            }
            userAnnotationView?.userBalloon.setUser(userAnnotation.user)

            return userAnnotationView
        }

        if let pinAnnotation = annotation as? GZEPinAnnotation {
            var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "GZEPinAnnotationView") as? GZEPinAnnotationView

            if pinAnnotationView == nil {
                pinAnnotationView = GZEPinAnnotationView(annotation: pinAnnotation, reuseIdentifier: "GZEPinAnnotationView")
            } else {
                pinAnnotationView?.annotation = pinAnnotation
            }
            pinAnnotationView?.canShowCallout = true

            return pinAnnotationView
        }

        if let pointAnnotation = annotation as? MKPointAnnotation {
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "GZEPointAnnotation") as? MKPinAnnotationView

            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "GZEPointAnnotation")
            } else {
                pinView?.annotation = pointAnnotation
            }
            pinView?.pinTintColor = GZEConstants.Color.pinColor
            pinView?.animatesDrop = true
            pinView?.canShowCallout = true

            return pinView
        }

        return nil
    }
}
