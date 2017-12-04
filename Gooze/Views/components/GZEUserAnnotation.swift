//
//  GZEUserAnnotation.swift
//  Gooze
//
//  Created by Yussel on 12/3/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import MapKit

class GZEUserAnnotation: NSObject, MKAnnotation {

    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D

    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate

        super.init()
    }

    var subtitle: String? {
        return locationName
    }
    
}
