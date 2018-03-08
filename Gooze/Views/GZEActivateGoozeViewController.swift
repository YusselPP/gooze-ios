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

    let segueToProfile = "segueToProfile"

    enum Scene {
        case activate
        case search
        case searchResults
        case allResults
    }
    var scene = Scene.search

    let MAX_RESULTS_ON_MAP = 5

    let geocoder = CLGeocoder()
    let locationManager = CLLocationManager()

    var viewModel: GZEActivateGoozeViewModel!

    var activateGoozeAction: CocoaAction<UIButton>!
    var searchGoozeAction: CocoaAction<UIButton>!
    var allResultsAction: CocoaAction<UIButton>!

    var isInitialPositionSet = false

    var sliderPostfix = "km"
    var sliderStep: Float = 1

    var userBalloons = [GZEUserBalloon]()
    var tappedUser: GZEUser?
    var searchAnimationEnabled = false

    var backButton = GZEBackUIBarButtonItem()

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

    @IBOutlet weak var usersListCollectionView: GZEUsersListCollectionView!
    @IBOutlet weak var usersListBackground: UIView!

    var onFindUserEvent: ((Event<GZEUser, GZEError>) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        createWeakMethods()
        setupInterfaceObjects()
        setupBindings()

        showScene()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createWeakMethods() {
        onFindUserEvent = ptr(self, GZEActivateGoozeViewController.findUserEventHandler)
    }

    func setupInterfaceObjects() {
        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true

        backButton.onButtonTapped = ptr(self, GZEActivateGoozeViewController.backButtonTapped)
        navigationItem.setLeftBarButton(backButton, animated: false)

        searchingRadiusView.alpha = 0

        userBalloons.append(userBalloon1)
        userBalloons.append(userBalloon2)
        userBalloons.append(userBalloon3)
        userBalloons.append(userBalloon4)
        userBalloons.append(userBalloon5)

        userBalloons.forEach {
            $0.onTap = ptr(self, GZEActivateGoozeViewController.userBalloonTapped)
        }

        usersListCollectionView.onUserTap = ptr(self, GZEActivateGoozeViewController.userBalloonTapped)
        usersListBackground.layer.cornerRadius = 15
        usersListBackground.layer.masksToBounds = true

        setupSlider()
    }

    func setupBindings() {
        viewModel.sliderValue <~ topSlider.reactive.values

        sliderLabel.reactive.text <~ viewModel.sliderValue.map { [unowned self] in "\($0) \(self.sliderPostfix)" }

        activateGoozeAction = CocoaAction(viewModel.activateGoozeAction)
        searchGoozeAction = CocoaAction(viewModel.searchGoozeAction)
        allResultsAction = CocoaAction(viewModel.searchGoozeAction)

        viewModel.findGoozeAction.events.observeValues(onFindUserEvent)

        viewModel.searchGoozeAction.values.observeValues { [unowned self] users in
            switch self.scene {
            case .search:
                self.showSearchResultsScene()
                self.searchAnimationEnabled = true
                self.startSearchAnimation()
                self.showResultsOnMap(users)
            case .searchResults:
                self.showAllResultsScene()
                self.showResultsOnList(users)
            default: break
            }
        }

        viewModel.searchGoozeAction.errors.observeValues { [weak self] in
            self?.displayMessage("Gooze", $0.localizedDescription)
        }

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

            self.userBalloons[index].setUser(user) { [weak self] in
                loadCompleteCount += 1
                if loadCompleteCount == resultsLimit {
                    self?.stopSearchAnimation()
                }
            }
        }
    }

    func hideResultsOnMap() {
        self.userBalloons.forEach { $0.setVisible(false) }
    }

    func showResultsOnList(_ users: [GZEUser]) {
        usersListCollectionView.users = users
        usersListCollectionView.reloadData()
    }

    func startSearchAnimation() {
        let scale: CGFloat = max(view.bounds.width, view.bounds.height) / 8

        let scaledTransform = searchingRadiusView.transform.scaledBy(x: scale, y: scale)
        let originalTransform = searchingRadiusView.transform

        searchingRadiusView.alpha = 1

        UIView.animate(withDuration: 3, animations: { [weak self] in

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

    func userBalloonTapped(_ tapRecognizer: UITapGestureRecognizer, _ userBalloon: GZEUserBalloon) {
        showLoading()

        if let userId = userBalloon.user?.id {
            viewModel.findGoozeAction.apply(userId).start()
        } else {
            hideLoading()
        }
    }

    func backButtonTapped(_ sender: Any) {
        switch scene {
        case .activate,
             .search:
            previousController(animated: true)
        case .searchResults:
            showSearchScene()
        case .allResults:
            showSearchScene()
        }

    }

    // MARK: - CocoaAction Observers
    private func findUserEventHandler(event: Event<GZEUser, GZEError>) {
        hideLoading()
        switch event {
        case .value(let user):
            performSegue(withIdentifier: segueToProfile, sender: user)
        case .failed(let err):
            onActionError(err)
        default:
            break;
        }
    }

    func onActionError(_ err: GZEError) {
        self.displayMessage(GZEAppConfig.appTitle, err.localizedDescription)
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


     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if
            segue.identifier == segueToProfile,
            let pageViewController = segue.destination as? GZEProfilePageViewController {

            if let user = sender as? GZEUser {
                pageViewController.profileVm = GZEProfileViewModelReadOnly(user: user)
                pageViewController.galleryVm = GZEGalleryViewModelReadOnly(user: user)
                pageViewController.ratingsVm = GZERatingsViewModelReadOnly(user: user)
            } else {
                log.error("Unable to obatain the user from segue sender")
            }
        }
     }

    // MARK: - Scenes
    func showScene() {
        switch scene {
        case .activate: showActivateScene()
        case .search: showSearchScene()
        case .searchResults: showSearchResultsScene()
        case .allResults : showAllResultsScene()
        }
    }

    func showActivateScene() {
        scene = .activate
        activateGoozeButton.setTitle(viewModel.activateButtonTitle, for: .normal)
        activateGoozeButton.reactive.pressed = activateGoozeAction

        distanceView.isHidden = false
        sliderLabel.isHidden = false
        topSlider.isHidden = false
        navIcon.isHidden = false
        usersListCollectionView.isHidden = true
        usersListBackground.isHidden = true
    }

    func showSearchScene() {
        scene = .search
        viewModel.searchLimit.value = MAX_RESULTS_ON_MAP

        activateGoozeButton.setTitle(viewModel.searchButtonTitle, for: .normal)
        activateGoozeButton.reactive.pressed = searchGoozeAction

        distanceView.isHidden = false
        sliderLabel.isHidden = false
        topSlider.isHidden = false
        navIcon.isHidden = false
        usersListCollectionView.isHidden = true
        usersListBackground.isHidden = true

        hideResultsOnMap()
    }

    func showSearchResultsScene() {
        scene = .searchResults
        viewModel.searchLimit.value = 50

        activateGoozeButton.setTitle(viewModel.allResultsButtonTitle, for: .normal)
        activateGoozeButton.reactive.pressed = searchGoozeAction

        distanceView.isHidden = true
        sliderLabel.isHidden = true
        topSlider.isHidden = true
        navIcon.isHidden = true
        usersListCollectionView.isHidden = true
        usersListBackground.isHidden = true
    }

    func showAllResultsScene() {
        scene = .allResults
        usersListCollectionView.isHidden = false
        usersListBackground.isHidden = false
        hideResultsOnMap()
    }

    // MARK: - Deinitializers
    deinit {
        mapView.delegate = nil
        log.debug("\(self) disposed")
    }
}
