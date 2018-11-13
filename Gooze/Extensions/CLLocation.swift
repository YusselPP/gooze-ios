//
//  CLLocation.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 11/11/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import CoreLocation
import ReactiveSwift

extension CLLocation {
    func toAddress() -> SignalProducer<String, GZEError> {
        var address = ""
        let geocoder = CLGeocoder()

        return SignalProducer{sink, dispose in

            dispose.add {
                log.debug("to adress producer disposed")
            }

            /*guard let this = self else {
                sink.send(error: .repository(error: .UnexpectedError))
                return
            }*/

            geocoder.reverseGeocodeLocation(self) { (placemarks, error) in
                if let coderError = error {
                    // An error occurred during geocoding.
                    sink.send(error: .message(text: coderError.localizedDescription, args: []))
                    return
                }

                if let place = placemarks?.first {
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
                }

                sink.send(value: address)
                sink.sendCompleted()
            }
        }
    }
}
