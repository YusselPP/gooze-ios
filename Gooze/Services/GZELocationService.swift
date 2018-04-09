//
//  GZELocationService.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/5/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import CoreLocation
import ReactiveSwift

class GZELocationService: NSObject, CLLocationManagerDelegate {
    
    static let shared = GZELocationService()
    
    let locationManager  = CLLocationManager()
    let lastLocation = MutableProperty<CLLocation?>(nil)
    let lastError = MutableProperty<Error?>(nil)
    var continuousLocation = false
    
    // MARK: - init
    override init() {
        super.init()
        self.locationManager.delegate = self
    }
    
    func requestAuthorization() -> String? {
        let status  = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            log.debug("Location services status not determined. Requesting authorization to the user.")
            self.locationManager.requestWhenInUseAuthorization()
            return nil
        } else if status == .denied || status == .restricted {
            log.debug("Location services disabled. Please enable Location Services in Settings.")
            return "service.location.disabled".localized()
        }
        
        return nil
    }
    
    func startUpdatingLocation(continuousLocation: Bool = false) {
        self.continuousLocation = continuousLocation
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last!
        log.debug("Current location: \(currentLocation)")
        self.lastLocation.value = currentLocation
        if !self.continuousLocation {
            self.locationManager.stopUpdatingLocation()
        }
    }
    

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log.error("Error \(error)")
        self.lastError.value = error
    }
}
