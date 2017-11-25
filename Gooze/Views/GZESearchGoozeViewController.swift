//
//  GZESearchGoozeViewController.swift
//  Gooze
//
//  Created by Yussel Paredes on 10/25/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI

class GZESearchGoozeViewController: UIViewController {

    var viewModel: GZESearchGoozeViewModel!

    let geocoder = CLGeocoder()
    let locationManager = CLLocationManager()

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var timeSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")
        // Do any additional setup after loading the view.
        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true
        setDistanceText(distanceSlider.value)
        setTimeText(timeSlider.value)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {

        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let loginController = mainStoryboard.instantiateViewController(withIdentifier: "GZELoginViewController") as? GZELoginViewController {

            // Set up initial view model
            loginController.viewModel = GZELoginViewModel(GZEUserApiRepository())
            setRootController(controller: loginController)
        } else {
            log.error("Unable to instantiate InitialViewController")
            displayMessage("Unexpected error", "Please contact support")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func distanceSliderChanged(_ sender: UISlider) {
        let step: Float = 1
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        setDistanceText(sender.value)
    }

    @IBAction func timeSliderChanged(_ sender: UISlider) {
        let step: Float = 0.5
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        setTimeText(sender.value)
    }

    @IBAction func enableGoozeButtonTapped(_ sender: UIButton) {
        let coord = mapView.centerCoordinate

        var message = "ACTIVO POR: \(timeSlider.value) hrs\nRANGO: \(distanceSlider.value) kms\nLAT: \(round(coord.latitude * 1000)/1000)\nLNG: \(round(coord.longitude * 1000)/1000)"

        log.debug(mapView.userLocation.location)

        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            log.debug(placemarks)
            log.debug(error)
            if let error = error {
                // An error occurred during geocoding.
                self?.displayMessage("No se pudo obtener la ubicación", error.localizedDescription)
            }
            else {

                let firstLocation = placemarks?[0]

                if  let dic = firstLocation?.addressDictionary {

                    let subtitle = ABCreateStringWithAddressDictionary(dic, false)
                    message = "LUGAR: \(subtitle.description)\n" + message
                }

                self?.displayMessage("Gooze", message)
            }

        }

    }

    @IBAction func unwindToSearchGooze(segue: UIStoryboardSegue) {
        log.debug("unwindToSearchGooze")
    }

    func setDistanceText(_ value: Float) {
        distanceLabel.text = "\(value) km"
    }

    func setTimeText(_ value: Float) {
        timeLabel.text = "\(value) hrs"
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
