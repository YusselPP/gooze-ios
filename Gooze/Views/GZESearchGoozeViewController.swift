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

    @IBOutlet weak var distanceSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")
        // Do any additional setup after loading the view.
        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true
        setDistanceText(distanceSlider.value)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    func setDistanceText(_ value: Float) {
        distanceLabel.text = "\(value) km"
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
