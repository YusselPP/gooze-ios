//
//  GZEPinAnnotation.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/7/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import MapKit

class GZEPinAnnotation: NSObject, MKAnnotation {

    dynamic var coordinate = CLLocationCoordinate2D() {
        didSet {
            self.setAddress()
        }
    }

    var title: String? {
        return self._title
    }

    var subtitle: String? {
        return self._subtitle
    }

    private var _title = "vm.pinAnnotation.pinTitle".localized()
    private var _subtitle: String?

    override init() {
        super.init()
    }

    func setAddress() {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)) { (placemarks, error) in
            if error == nil {
                if let place = placemarks?.first {
                    var address = ""

                    if let thoroughfare = place.thoroughfare {
                        address += thoroughfare
                    }

                    if let subThoroughfare = place.subThoroughfare {
                        address += (!address.isEmpty ? ", " : "") + subThoroughfare
                    }

                    if let subLocality = place.subLocality {
                        address += (!address.isEmpty ? ", " : "") + subLocality
                    }

                    if let locality = place.locality {
                        address += (!address.isEmpty ? ", " : "") + locality
                    }

                    if let country = place.country {
                        address += (!address.isEmpty ? ", " : "") + country
                    }

                    if let postalCode = place.postalCode {
                        address += (!address.isEmpty ? ", " : "") + postalCode
                    }

                    self._subtitle = address
                }
            }
            else {
                // An error occurred during geocoding.
                self._subtitle = "vm.pinAnnotation.loading".localized()
            }
        }
    }
}
