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

class GZEMapService {

    static let shared = GZEMapService()

    let mapView = MKMapView()

    var disposables = [Disposable?]()

    func cleanMap() {
        self.mapView.removeFromSuperview()
        self.mapView.delegate = nil
        self.mapView.showsUserLocation = false
        self.mapView.removeAnnotations(self.mapView.annotations)

        self.disposables.forEach{$0?.dispose()}
        self.disposables.removeAll()
    }
}
