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
        case activated

        case search
        case searching
        case searchResults
        case resultsList
        case otherResultsList
    }
    var scene = Scene.search {
        didSet {
            handleSceneChanged()
        }
    }

    let MAX_RESULTS_ON_MAP = 5

    let geocoder = CLGeocoder()
    let locationManager = CLLocationManager()

    var viewModel: GZEActivateGoozeViewModel!

    var activateGoozeAction: CocoaAction<GZEButton>!
    var searchGoozeAction: CocoaAction<GZEButton>!
    var allResultsAction: CocoaAction<GZEButton>!

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

    @IBOutlet weak var activateGoozeButton: GZEButton!

    @IBOutlet weak var userBalloon1: GZEUserBalloon!
    @IBOutlet weak var userBalloon2: GZEUserBalloon!
    @IBOutlet weak var userBalloon3: GZEUserBalloon!
    @IBOutlet weak var userBalloon4: GZEUserBalloon!
    @IBOutlet weak var userBalloon5: GZEUserBalloon!

    // Top controls
    @IBOutlet weak var navIcon: UIImageView!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var topSlider: UISlider!
    @IBOutlet weak var topControls: UIView!
    @IBOutlet weak var topControlsBackground: UIView!

    @IBOutlet weak var searchingRadiusView: UIImageView!

    @IBOutlet weak var usersListCollectionView: GZEUsersListCollectionView!
    @IBOutlet weak var usersListBackground: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        setupInterfaceObjects()
        setupBindings()

        handleSceneChanged()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupInterfaceObjects() {
        locationManager.requestAlwaysAuthorization()
        mapView.showsUserLocation = true

        backButton.onButtonTapped = ptr(self, GZEActivateGoozeViewController.backButtonTapped)
        navigationItem.setLeftBarButton(backButton, animated: false)

        activateGoozeButton.setGrayFormat()

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

        activateGoozeAction = CocoaAction(viewModel.activateGoozeAction) { [weak self] _ in
                self?.searchAnimationEnabled = true
                self?.startSearchAnimation()
                self?.activateGoozeButton.setGrayFormatToggled()
            }
        searchGoozeAction = CocoaAction(viewModel.searchGoozeAction)
        allResultsAction = CocoaAction(viewModel.searchGoozeAction)

        viewModel.findGoozeAction.events.observeValues(onUserEvent)

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

        viewModel.activateGoozeAction.events.observeValues(onUserEvent)

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
        case .resultsList:
            showSearchScene()
        }

    }

    // MARK: - CocoaAction Observers
    private func onUserEvent(_ event: Event<GZEUser, GZEError>) {
        hideLoading()
        switch event {
        case .value(let user):
            switch scene {
            case .searchResults,
                    .resultsList:
                performSegue(withIdentifier: segueToProfile, sender: user)
            default: break
            }
        case .failed(let err):
            onActionError(err)
        default:
            break;
        }
    }

    func onActionError(_ err: GZEError) {
        self.displayMessage(GZEAppConfig.appTitle, err.localizedDescription)
        if scene == .activate {
            self.activateGoozeButton.setGrayFormat()
            self.stopSearchAnimation()
        }
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
    func handleSceneChanged() {
        hideAll()
        switch scene {
        case .activate: showActivateScene()
        case .activated: showActivatedScene()

        case .search: showSearchScene()
        case .searching: showSearchingScene()
        case .searchResults: showSearchResultsScene()
        case .resultsList : showAllResultsScene()
        case .otherResultsList: showOtherResultsListScene()
        }
    }

    func hideAll() {
        topControls.isHidden = true
        topControlsBackground.isHidden = true
        usersListCollectionView.isHidden = true
        usersListBackground.isHidden = true
    }

    func showActivateScene() {
        topControls.isHidden = false
        topControlsBackground.isHidden = false

        activateGoozeButton.setTitle(viewModel.activateButtonTitle.uppercased(), for: .normal)
        activateGoozeButton.reactive.pressed = activateGoozeAction
    }

    func showActivatedScene() {

    }

    func showSearchScene() {
        topControls.isHidden = false
        topControlsBackground.isHidden = false

        viewModel.searchLimit.value = MAX_RESULTS_ON_MAP

        activateGoozeButton.setTitle(viewModel.searchButtonTitle.uppercased(), for: .normal)
        activateGoozeButton.reactive.pressed = searchGoozeAction

        hideResultsOnMap()
    }

    func showSearchingScene() {

    }

    func showSearchResultsScene() {
        viewModel.searchLimit.value = 50

        activateGoozeButton.setTitle(viewModel.allResultsButtonTitle.uppercased(), for: .normal)
        activateGoozeButton.reactive.pressed = searchGoozeAction
    }

    func showAllResultsScene() {
        usersListCollectionView.isHidden = false
        usersListBackground.isHidden = false
        hideResultsOnMap()
    }

    func showOtherResultsListScene() {
        usersListCollectionView.isHidden = false
        usersListBackground.isHidden = false
    }

    // MARK: - Deinitializers
    deinit {
        mapView.delegate = nil
        log.debug("\(self) disposed")
    }
}
