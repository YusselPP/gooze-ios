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
    var allResultsAction: CocoaAction<UIButton>!

    enum Scene {
        case activate
        case search
        case allResults
    }
    var scene = Scene.search
    var isInitialPositionSet = false

    var userBalloons = [GZEUserBalloon]()
    var searchAnimationEnabled = false

    let MAX_RESULTS_ON_MAP = 5

    var backButton = UIBarButtonItem()

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

    @IBOutlet weak var searchingRadiusView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true

        backButton.target = self
        backButton.image = #imageLiteral(resourceName: "icons8-back-50")
        navigationItem.setLeftBarButton(backButton, animated: false)

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
        searchGoozeAction = CocoaAction(viewModel.searchGoozeAction) { [unowned self] _ in
            self.showSearchResultsScene()
        }
        allResultsAction = CocoaAction(viewModel.searchGoozeAction) { [unowned self] _ in
            self.showAllResultsScene()
        }

        viewModel.searchGoozeAction.values.observeValues { [unowned self] users in
            switch self.scene {
            case .search:
                self.searchAnimationEnabled = true
                self.startSearchAnimation()
                self.showResultsOnMap(users)
            case .allResults:
                self.showResultsOnList(users)
            default: break
            }
        }

        viewModel.searchGoozeAction.errors.observeValues { [weak self] in
            self?.displayMessage("Gooze", $0.localizedDescription)
        }

        switch scene {
        case .activate:
            showActivateScene()
        default:
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

        backButton.action = #selector(previousController)
    }

    func showSearchScene() {
        viewModel.searchLimit.value = MAX_RESULTS_ON_MAP

        activateGoozeButton.setTitle(viewModel.searchButtonTitle, for: .normal)
        activateGoozeButton.reactive.pressed = searchGoozeAction

        distanceView.isHidden = false
        distanceLabel.isHidden = false
        distanceSlider.isHidden = false
        navIcon.isHidden = false

        timeView.isHidden = true
        timeLabel.isHidden = true
        timeSlider.isHidden = true

        backButton.action = #selector(previousController)

        hideResultsOnMap()
    }

    func showSearchResultsScene() {
        viewModel.searchLimit.value = 50

        activateGoozeButton.setTitle(viewModel.allResultsButtonTitle, for: .normal)
        activateGoozeButton.reactive.pressed = searchGoozeAction

        distanceView.isHidden = true
        distanceLabel.isHidden = true
        distanceSlider.isHidden = true
        navIcon.isHidden = true

        backButton.action = #selector(showSearchScene)
    }

    func showAllResultsScene() {
        
    }

    func showResultsOnMap(_ users: [GZEUser]) {
        hideResultsOnMap()

        if users.count == 0 {
            self.stopSearchAnimation()
        }

        var loadCompleteCount = 0

        let resultsLimit = min(users.count, MAX_RESULTS_ON_MAP)

        for index in 0..<resultsLimit {

            let user = users[index]

            self.userBalloons[index].rating = 4.5

            if let urlRequest = user.profilePic?.urlRequest {
                self.userBalloons[index].setImage(urlRequest: urlRequest) { [weak self] in
                    loadCompleteCount += 1

                    if loadCompleteCount == resultsLimit {
                        self?.stopSearchAnimation()
                    }
                }

            } else {
                loadCompleteCount += 1

                if loadCompleteCount == resultsLimit {
                    self.stopSearchAnimation()
                }
                self.userBalloons[index].setVisible(true)
                log.error("Failed to set image url for user id=[\(String(describing: user.id))]")
            }
        }
    }

    func hideResultsOnMap() {
        self.userBalloons.forEach { $0.setVisible(false) }
    }

    func showResultsOnList(_ users: [GZEUser]) {

    }

    func startSearchAnimation() {
        let scale: CGFloat = 30

        let scaledTransform = searchingRadiusView.transform.scaledBy(x: scale, y: scale)
        let originalTransform = searchingRadiusView.transform

        UIView.animate(withDuration: 1, animations: { [weak self] in

            guard let this = self else {
                return
            }

            this.searchingRadiusView.transform = scaledTransform
        }, completion: { [weak self] _ in

            guard let this = self else {
                return
            }
            
            this.searchingRadiusView.transform = originalTransform

            if this.searchAnimationEnabled {
                this.startSearchAnimation()
            }
        })

    }

    func stopSearchAnimation() {
        searchAnimationEnabled = false
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

    func previousController() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: Deinitializers
    deinit {
        mapView.delegate = nil
        log.debug("\(self) disposed")
    }
}
