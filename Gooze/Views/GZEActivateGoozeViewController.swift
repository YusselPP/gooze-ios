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

    enum Scene {
        case activate
        case search
        case allResults
    }

    let MAX_RESULTS_ON_MAP = 5

    let geocoder = CLGeocoder()
    let locationManager = CLLocationManager()

    var viewModel: GZEActivateGoozeViewModel!

    var activateGoozeAction: CocoaAction<UIButton>!
    var searchGoozeAction: CocoaAction<UIButton>!
    var allResultsAction: CocoaAction<UIButton>!

    var scene = Scene.search
    var isInitialPositionSet = false

    var sliderPostfix = "km"
    var sliderStep: Float = 1

    var userBalloons = [GZEUserBalloon]()
    var searchAnimationEnabled = false

    var backButton = UIBarButtonItem()

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var topSlider: UISlider!

    @IBOutlet weak var activateGoozeButton: UIButton!

    @IBOutlet weak var userBalloon1: GZEUserBalloon!
    @IBOutlet weak var userBalloon2: GZEUserBalloon!
    @IBOutlet weak var userBalloon3: GZEUserBalloon!
    @IBOutlet weak var userBalloon4: GZEUserBalloon!
    @IBOutlet weak var userBalloon5: GZEUserBalloon!

    @IBOutlet weak var distanceView: UIView!
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

        searchingRadiusView.alpha = 0

        userBalloons.append(userBalloon1)
        userBalloons.append(userBalloon2)
        userBalloons.append(userBalloon3)
        userBalloons.append(userBalloon4)
        userBalloons.append(userBalloon5)

        viewModel.sliderValue <~ topSlider.reactive.values

        sliderLabel.reactive.text <~ viewModel.sliderValue.map { [unowned self] in "\($0) \(self.sliderPostfix)" }

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

        setupSlider()

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

        distanceView.isHidden = false
        sliderLabel.isHidden = false
        topSlider.isHidden = false
        navIcon.isHidden = false

        backButton.action = #selector(previousController)
    }

    func showSearchScene() {
        viewModel.searchLimit.value = MAX_RESULTS_ON_MAP

        activateGoozeButton.setTitle(viewModel.searchButtonTitle, for: .normal)
        activateGoozeButton.reactive.pressed = searchGoozeAction

        distanceView.isHidden = false
        sliderLabel.isHidden = false
        topSlider.isHidden = false
        navIcon.isHidden = false

        backButton.action = #selector(previousController)

        hideResultsOnMap()
    }

    func showSearchResultsScene() {
        viewModel.searchLimit.value = 50

        activateGoozeButton.setTitle(viewModel.allResultsButtonTitle, for: .normal)
        activateGoozeButton.reactive.pressed = searchGoozeAction

        distanceView.isHidden = true
        sliderLabel.isHidden = true
        topSlider.isHidden = true
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
        let scale: CGFloat = max(view.bounds.width, view.bounds.height) / 8

        let scaledTransform = searchingRadiusView.transform.scaledBy(x: scale, y: scale)
        let originalTransform = searchingRadiusView.transform

        searchingRadiusView.alpha = 1

        UIView.animate(withDuration: 1, animations: { [weak self] in

            guard let this = self else {
                return
            }

            this.searchingRadiusView.transform = scaledTransform
            this.searchingRadiusView.alpha = 0
        }, completion: { [weak self] _ in

            guard let this = self else {
                return
            }
            
            this.searchingRadiusView.transform = originalTransform
            this.searchingRadiusView.alpha = 1

            if this.searchAnimationEnabled {
                this.startSearchAnimation()
            }
        })

    }

    func stopSearchAnimation() {
        searchAnimationEnabled = false
        searchingRadiusView.alpha = 0
    }

    func setupSlider() {
        if self.scene == .activate {
            sliderPostfix = "hrs"
            sliderStep = 0.5

            topSlider.maximumValue = 5
            topSlider.value = 1
            viewModel.sliderValue.value = 1
        } else {
            sliderPostfix = "kms"
            sliderStep = 1

            topSlider.maximumValue = 50
            topSlider.value = 1
            viewModel.sliderValue.value = 1
        }
    }

    // MARK: - UIActions

    @IBAction func topSliderChanged(_ sender: UISlider) {
        let roundedValue = round(sender.value / sliderStep) * sliderStep
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
