//
//  GZEActivateGoozeViewController.swift
//  Gooze
//
//  Created by Yussel on 11/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import MapKit
import AddressBookUI

class GZEActivateGoozeViewController: UIViewController {

    var viewModel: GZEActivateGoozeViewModel!

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

        if
            let navController = mainStoryboard.instantiateViewController(withIdentifier: "LoginNavController") as? UINavigationController,
            let loginController = navController.viewControllers.first as? GZELoginViewController {

            // Set up initial view model
            loginController.viewModel = GZELoginViewModel(GZEUserApiRepository())
            setRootController(controller: navController)
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

        var message = "ACTIVO POR: \(timeSlider.value) hrs\nRANGO: \(distanceSlider.value) kms\nLAT: \(coord.latitude)\nLNG: \(coord.longitude)"

        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in

            if let error = error {
                // An error occurred during geocoding.
                log.error(error)
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