//
//  GZEActivateGoozeViewController.swift
//  Gooze
//
//  Created by Yussel on 11/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import MapKit
import ReactiveSwift
import ReactiveCocoa

class GZEActivateGoozeViewController: UIViewController, MKMapViewDelegate {

    var viewModel: GZEActivateGoozeViewModel!

    let geocoder = CLGeocoder()
    let locationManager = CLLocationManager()

    var activateGoozeAction: CocoaAction<UIButton>!
    var searchGoozeAction: CocoaAction<UIButton>!

    enum Scene {
        case activate
        case search
    }
    var scene = Scene.search
    var isInitialPositionSet = false

    var userBalloons = [GZEUserBalloon]()

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var timeSlider: UISlider!

    @IBOutlet weak var activateGoozeButton: UIButton!

    @IBOutlet weak var userBalloon1: GZEUserBalloon!
    @IBOutlet weak var userBalloon2: GZEUserBalloon!
    @IBOutlet weak var userBalloon3: GZEUserBalloon!
    @IBOutlet weak var userBalloon4: GZEUserBalloon!
    @IBOutlet weak var userBalloon5: GZEUserBalloon!

    @IBOutlet weak var distanceView: UIView!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var navIcon: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true

        userBalloons.append(userBalloon1)
        userBalloons.append(userBalloon2)
        userBalloons.append(userBalloon3)
        userBalloons.append(userBalloon4)
        userBalloons.append(userBalloon5)

        viewModel.radiusDistance <~ distanceSlider.reactive.values
        viewModel.activeTime <~ timeSlider.reactive.values

        distanceLabel.reactive.text <~ viewModel.radiusDistance.map { "\($0) km" }
        timeLabel.reactive.text <~ viewModel.activeTime.map { "\($0) hrs" }

        activateGoozeAction = CocoaAction(viewModel.activateGoozeAction)
        searchGoozeAction = CocoaAction(viewModel.searchGoozeAction)

        viewModel.searchGoozeAction.values.observeValues { [unowned self] users in

            self.userBalloons.forEach { $0.setVisible(false) }

            for (index, user) in users.enumerated() {

                if let urlRequest = user.photos?.first?.urlRequest {
                    self.userBalloons[index].setImage(urlRequest: urlRequest)
                    self.userBalloons[index].rating = 4.5
                } else {
                    log.error("Failed to set image url for user id=[\(String(describing: user.id))]")
                }
            }
        }

        switch scene {
        case .activate:
            showActivateScene()
        case .search:
            showSearchScene()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func showActivateScene() {
        
        activateGoozeButton.setTitle(viewModel.activateButtonTitle, for: .normal)
        activateGoozeButton.reactive.pressed = activateGoozeAction

        distanceView.isHidden = true
        distanceLabel.isHidden = true
        distanceSlider.isHidden = true
        navIcon.isHidden = true

        timeView.isHidden = false
        timeLabel.isHidden = false
        timeSlider.isHidden = false
    }

    func showSearchScene() {
        activateGoozeButton.setTitle(viewModel.searchButtonTitle, for: .normal)
        activateGoozeButton.reactive.pressed = searchGoozeAction

        distanceView.isHidden = false
        distanceLabel.isHidden = false
        distanceSlider.isHidden = false
        navIcon.isHidden = false

        timeView.isHidden = true
        timeLabel.isHidden = true
        timeSlider.isHidden = true
    }

    // MARK: - UIActions

    @IBAction func distanceSliderChanged(_ sender: UISlider) {
        let step: Float = 1
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
    }

    @IBAction func timeSliderChanged(_ sender: UISlider) {
        let step: Float = 0.5
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
    }

    // MARK: - Map Delegate

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        log.debug("Map region changed. Center=[\(mapView.centerCoordinate)]")
        viewModel.currentLocation.value = mapView.centerCoordinate
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {

        if isInitialPositionSet { return }

        log.debug("User location updated: \(mapView.userLocation.coordinate)")
        mapView.setRegion(MKCoordinateRegionMake(mapView.userLocation.coordinate, MKCoordinateSpanMake(0.1, 0.1)), animated: true)
        isInitialPositionSet = true
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

    // MARK: Deinitializers
    deinit {
        mapView.delegate = nil
        log.debug("\(self) disposed")
    }
}
