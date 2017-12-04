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
    var userAnnotations = [GZEUserAnnotation]()

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
    @IBOutlet weak var userBalloon: GZEUserBalloon!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true

        userBalloon.imageView.image = #imageLiteral(resourceName: "Unknown")

        viewModel.radiusDistance <~ distanceSlider.reactive.values
        viewModel.activeTime <~ timeSlider.reactive.values

        distanceLabel.reactive.text <~ viewModel.radiusDistance.map { "\($0) km" }
        timeLabel.reactive.text <~ viewModel.activeTime.map { "\($0) hrs" }

        activateGoozeAction = CocoaAction(viewModel.activateGoozeAction)
        searchGoozeAction = CocoaAction(viewModel.searchGoozeAction)

        viewModel.searchGoozeAction.values.observeValues { [unowned self] users in
            self.mapView.removeAnnotations(self.userAnnotations)
            self.userAnnotations.removeAll(keepingCapacity: true)
            for user in users {
                self.userAnnotations.append(GZEUserAnnotation(title: user.username!, locationName: user.id!, discipline: "discipline", coordinate: user.currentLocation!.toCoreLocationCoordinate2D()))
            }

            self.userBalloon.setVisible(users.count > 0)

            self.mapView.addAnnotations(self.userAnnotations)
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
    }

    func showSearchScene() {
        activateGoozeButton.setTitle(viewModel.searchButtonTitle, for: .normal)
        activateGoozeButton.reactive.pressed = searchGoozeAction
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
