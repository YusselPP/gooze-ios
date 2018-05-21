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
    let lastError = MutableProperty<String?>(nil)
    
    // MARK: - init
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 100
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.allowsBackgroundLocationUpdates = false // enable background updates only when needed
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
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

    func requestLocation() {
        if let authorizationMessage = self.requestAuthorization() {
            self.lastError.value = authorizationMessage
        } else {
            self.locationManager.requestLocation()
        }
    }
    
    func startUpdatingLocation(background: Bool = false) {
        if let authorizationMessage = self.requestAuthorization() {
            self.lastError.value = authorizationMessage
        } else {
            self.locationManager.allowsBackgroundLocationUpdates = background
            self.locationManager.startUpdatingLocation()
        }
    }

    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }

    // MARK - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last!
        log.debug("Current location: \(currentLocation)")
        self.lastLocation.value = currentLocation
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log.error("Error \(error)")
        self.lastError.value = error.localizedDescription
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        log.debug("location manager did pause")
    }

    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        log.debug("location manager did resume")
    }

}
