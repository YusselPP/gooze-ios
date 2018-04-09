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
        case requestResults
        case requestResultsList
        case requestOtherResultsList

        case search
        case searching
        case searchResults
        case resultsList
        case otherResultsList
    }
    var scene = Scene.search {
        didSet {
            if isViewLoaded {
                handleSceneChanged()
            }
        }
    }

    let MAX_RESULTS_ON_MAP = 5
    let MAX_RESULTS = 50

    let geocoder = CLGeocoder()
    let locationService = GZELocationService.shared

    var viewModel: GZEActivateGoozeViewModel!

    var activateGoozeAction: CocoaAction<GZEButton>!
    var deactivateGoozeAction: CocoaAction<GZEButton>!
    var searchGoozeAction: CocoaAction<GZEButton>!
    var showResultsListAction: CocoaAction<GZEButton>!
    var showOtherResultsListAction: CocoaAction<GZEButton>!
    var showRequestResultsListAction: CocoaAction<GZEButton>!
    var showRequestOtherResultsListAction: CocoaAction<GZEButton>!

    var disposeRequestsObserver: Disposable?
    var isInitialPositionSet = false

    var sliderPostfix = "km"
    var sliderStep: Float = 1

    var userBalloons = [GZEUserBalloon]()
    var tappedUserConvertible: GZEUserConvertible?

    var isSearchingAnimationEnabled = false {
        didSet {
            if isSearchingAnimationEnabled {
                log.debug("starting search radius animation")
                startSearchAnimation()
            } else {
                log.debug("stopping search radius animation")
                stopSearchAnimation()
            }
        }
    }
    var isSearchAnimationInProgress = false
    var shouldRestartSearchingAnmiation = false

    let usersList = GZEUsersList()

    var backButton = GZEBackUIBarButtonItem()

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activateGoozeButton: GZEButton!

    @IBOutlet weak var userBalloon1: GZEUserBalloon!
    @IBOutlet weak var userBalloon2: GZEUserBalloon!
    @IBOutlet weak var userBalloon3: GZEUserBalloon!
    @IBOutlet weak var userBalloon4: GZEUserBalloon!
    @IBOutlet weak var userBalloon5: GZEUserBalloon!

    // Top controls
    @IBOutlet weak var navIcon: UIView!
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var topSlider: UISlider!
    @IBOutlet weak var topControls: UIView!
    @IBOutlet weak var topControlsBackground: UIView!

    @IBOutlet weak var searchingRadiusView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        setupInterfaceObjects()
        setupBindings()

        handleSceneChanged()

        // TODO: load activate scene with the user current state(active/inactive)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.shouldRestartSearchingAnmiation {
            self.shouldRestartSearchingAnmiation = false
            self.isSearchingAnimationEnabled = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isSearchingAnimationEnabled {
            self.shouldRestartSearchingAnmiation = true
            self.isSearchingAnimationEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupInterfaceObjects() {
        mapView.showsUserLocation = true
        navIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(centerMapToUserLocation)))

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

        usersList.onUserTap = {[weak self] tapRecognizer, userBalloon in
            self?.userBalloonTapped(tapRecognizer, userBalloon)
        }

        setupSlider()

        self.containerView.addSubview(self.usersList)
        self.view.leadingAnchor.constraint(equalTo: self.usersList.leadingAnchor, constant: -20).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.usersList.trailingAnchor, constant: 20).isActive = true
        self.topLayoutGuide.bottomAnchor.constraint(equalTo: self.usersList.topAnchor, constant: -20).isActive = true
        self.bottomLayoutGuide.topAnchor.constraint(equalTo: self.usersList.bottomAnchor, constant: 20).isActive = true
    }

    func setupBindings() {
        viewModel.sliderValue <~ topSlider.reactive.values

        sliderLabel.reactive.text <~ viewModel.sliderValue.map { [unowned self] in "\($0) \(self.sliderPostfix)" }

        activateGoozeAction = CocoaAction(viewModel.activateGoozeAction) { [weak self] _ in
            self?.showLoading()
        }
        deactivateGoozeAction = CocoaAction(viewModel.deactivateGoozeAction) { [weak self] _ in
            self?.showLoading()
        }

        searchGoozeAction = CocoaAction(viewModel.searchGoozeAction) { [weak self] _ in
            self?.scene = .searching
        }
        showResultsListAction = CocoaAction(Action<Void,Void,GZEError>{SignalProducer.empty}) { [weak self] _ in
            self?.scene = .resultsList
        }
        showOtherResultsListAction = CocoaAction(Action<Void,Void,GZEError>{SignalProducer.empty}) { [weak self] _ in
            self?.scene = .otherResultsList
        }
        showRequestResultsListAction = CocoaAction(Action<Void,Void,GZEError>{SignalProducer.empty}) { [weak self] _ in
            self?.scene = .requestResultsList
        }
        showRequestOtherResultsListAction = CocoaAction(Action<Void,Void,GZEError>{SignalProducer.empty}) { [weak self] _ in
            self?.scene = .requestOtherResultsList
        }

        viewModel.findGoozeAction.events.observeValues {[weak self] in
            self?.onUserEvent($0)
        }
        viewModel.searchGoozeAction.events.observeValues {[weak self] in
            self?.onUserEvent($0)
        }
        viewModel.activateGoozeAction.events.observeValues {[weak self] in
            self?.onUserEvent($0)
        }
        viewModel.deactivateGoozeAction.events.observeValues {[weak self] in
            self?.onDeactivateEvents($0)
        }
    }



    func updateBalloons() {
        let users = viewModel.userResults.value
        if users.count == 0 {
            if scene == .searching {
                scene = .search
                GZEAlertService.shared.showBottomAlert(text: viewModel.zeroResultsMessage)
            }
        }

        var loadCompleteCount = 0

        let resultsLimit = min(users.count, MAX_RESULTS_ON_MAP)

        for index in 0..<resultsLimit {

            let user = users[index]

            self.userBalloons[index].setUser(user) { [weak self] in
                loadCompleteCount += 1
                if loadCompleteCount == resultsLimit {
                    if self?.scene == .searching {
                        self?.scene = .searchResults
                    }
                }
            }
        }
    }

    func showBalloons() {
        let resultsLimit = min(viewModel.userResults.value.count, MAX_RESULTS_ON_MAP)

        for index in 0..<resultsLimit {
            userBalloons[index].setVisible(true)
        }
    }
    func hideBalloons() {
        self.userBalloons.forEach { $0.setVisible(false) }
    }

    //func updateResultsOnList(_ users: [GZEUser]) {
    //    self.usersResults = users
    //}

    func startSearchAnimation() {

        if self.isSearchAnimationInProgress {
            return
        }

        self.isSearchAnimationInProgress = true

        searchingRadiusView.transform = .identity
        searchingRadiusView.alpha = 1

        let scale: CGFloat = max(view.bounds.width, view.bounds.height) / 8
        let scaledTransform = searchingRadiusView.transform.scaledBy(x: scale, y: scale)


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

            this.isSearchAnimationInProgress = false

            if this.isSearchingAnimationEnabled {
                this.startSearchAnimation()
            }
        })

    }

    func stopSearchAnimation() {
        searchingRadiusView.alpha = 0
    }

    func setupSlider() {
        if self.scene == .activate {
            sliderPostfix = "hrs"
            sliderStep = 0.5

            topSlider.maximumValue = 3
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
            tappedUserConvertible = userBalloon.userConvertible
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
            scene = .search
        case .resultsList:
            scene = .searchResults
        case .otherResultsList:
            scene = .searchResults
        case .requestResults:
            //scene = .activate
            deactivateGoozeAction.execute(activateGoozeButton)
        case .requestResultsList:
            scene = .requestResults
        case .requestOtherResultsList:
            scene = .requestResultsList
        default:
            break
        }

    }

    // MARK: - CocoaAction Observers
    private func onUserEvent<T>(_ event: Event<T, GZEError>) {
        log.debug("onUserEvent: \(event)")
        hideLoading()
        switch event {
        case .value(let user):
            switch scene {
            case .activate:
                scene = .requestResults
                GZEDatesService.shared.findUnrespondedRequests()

            case .searching:
                if let users = user as? [GZEUserConvertible] {
                    for user in users {
                        if let dateReq = user as? GZEDateRequest {
                            dateReq.userMode = .recipient
                        }
                    }
                    viewModel.userResults.value = users
                }
                updateBalloons()
                //updateResultsOnList()
            case .searchResults,
                 .resultsList,
                 .otherResultsList,
                 .requestResults,
                 .requestResultsList,
                 .requestOtherResultsList:
                performSegue(withIdentifier: segueToProfile, sender: user)
            default: break
            }
        case .failed(let err):
            onActionError(err)
        default:
            break;
        }
    }
    
    private func onDeactivateEvents<T>(_ event: Event<T, GZEError>) {
        log.debug("onDeactivateEvents: \(event)")
        hideLoading()
        switch event {
        case .value:
            scene = .activate
        case .failed(let err):
            onActionError(err)
        default:
            break;
        }
    }

    func onActionError(_ err: GZEError) {
        GZEAlertService.shared.showBottomAlert(text: err.localizedDescription)
        if scene == .activate {
            self.activateGoozeButton.setGrayFormat()
            self.stopSearchAnimation()
        } else if scene == .searching {
            scene = .search
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
        centerMapToUserLocation()
        isInitialPositionSet = true
    }

    func centerMapToUserLocation() {
        if let authorizationMessage = locationService.requestAuthorization() {
            GZEAlertService.shared.showBottomAlert(text: authorizationMessage)
        } else {
            mapView.setRegion(MKCoordinateRegionMake(mapView.userLocation.coordinate, MKCoordinateSpanMake(0.1, 0.1)), animated: true)
        }
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
                pageViewController.profileVm = GZEProfileUserInfoViewModelReadOnly(user: user)
                pageViewController.galleryVm = GZEGalleryViewModelReadOnly(user: user)
                pageViewController.ratingsVm = GZERatingsViewModelReadOnly(user: user)
                
                if
                    scene == .requestResults ||
                    scene == .requestResultsList ||
                    scene == .requestOtherResultsList
                {
                    pageViewController.profileVm.mode = .request
                    pageViewController.galleryVm.mode = .request
                    pageViewController.ratingsVm.mode = .request
                }
                
                let dateRequest = tappedUserConvertible as? GZEDateRequest
                
                pageViewController.profileVm.dateRequest = dateRequest
                pageViewController.galleryVm.dateRequest = dateRequest
                pageViewController.ratingsVm.dateRequest = dateRequest
            } else {
                log.error("Unable to obatain the user from segue sender")
            }
        }
     }

    // MARK: - Scenes
    func handleSceneChanged() {
        hideAll()
        GZEAlertService.shared.dismissBottomAlert()
        GZEAlertService.shared.dismissTopAlert()
        switch scene {
        case .activate: showActivateScene()
        case .requestResults: showRequestResultsScene()
        case .requestResultsList: showRequestResultsListScene()
        case .requestOtherResultsList: showRequestOtherResultsListScene()

        case .search: showSearchScene()
        case .searching: showSearchingScene()
        case .searchResults: showSearchResultsScene()
        case .resultsList : showAllResultsScene()
        case .otherResultsList: showOtherResultsListScene()
        }
        log.debug("scene changed: \(scene)")
    }

    func hideAll() {
        topControls.isHidden = true
        topControlsBackground.isHidden = true
        activateGoozeButton.isHidden = true
        switch scene {
        case .resultsList,
             .otherResultsList,
             .requestResultsList,
             .requestOtherResultsList:
            break
        default: usersList.dismiss()
        }
    }

    func showActivateScene() {
        topControls.isHidden = false
        topControlsBackground.isHidden = false
        activateGoozeButton.isHidden = false
        
        hideBalloons()

        mapView.isUserInteractionEnabled = true
        isSearchingAnimationEnabled = false

        activateGoozeButton.setTitle(viewModel.activateButtonTitle.uppercased(), for: .normal)
        activateGoozeButton.reactive.pressed = activateGoozeAction
        disposeRequestsObserver?.dispose()
        disposeRequestsObserver = nil
    }

    func showRequestResultsScene() {
        mapView.isUserInteractionEnabled = false
        isSearchingAnimationEnabled = true
        activateGoozeButton.isHidden = false
        activateGoozeButton.isEnabled = true
        activateGoozeButton.setTitle(viewModel.allResultsButtonTitle.uppercased(), for: .normal)
        activateGoozeButton.reactive.pressed = showRequestResultsListAction

        showBalloons()
        observeRequests()
    }

    func showRequestResultsListScene() {
        //disposeRequestsObserver?.dispose()
        //disposeRequestsObserver = nil
        hideBalloons()

        usersList.onDismiss = { [weak self] in
            self?.usersList.onDismiss = nil
            self?.scene = .requestResults
        }

        usersList.users = viewModel.userResults.value
        usersList.show()

        usersList.actionButton.setTitle(
            viewModel.otherResultsButtonTitle.uppercased(), for: .normal
        )
        usersList.actionButton.reactive.pressed = showRequestOtherResultsListAction
    }

    func showRequestOtherResultsListScene() {
        usersList.users = viewModel.userOtherResults.value
        usersList.actionButton.setTitle(viewModel.backButtonTitle.uppercased(), for: .normal)
        usersList.actionButton.reactive.pressed = showRequestResultsListAction
        GZEAlertService.shared.showTopAlert(text: viewModel.othersResultsWarning)
    }

    func showSearchScene() {
        topControls.isHidden = false
        topControlsBackground.isHidden = false
        activateGoozeButton.isHidden = false

        mapView.isUserInteractionEnabled = true
        isSearchingAnimationEnabled = false

        viewModel.searchLimit.value = MAX_RESULTS

        activateGoozeButton.isEnabled = true
        activateGoozeButton.setTitle(viewModel.searchButtonTitle.uppercased(), for: .normal)
        activateGoozeButton.reactive.pressed = searchGoozeAction

        hideBalloons()
    }

    func showSearchingScene() {
        mapView.isUserInteractionEnabled = false
        activateGoozeButton.isHidden = false

        isSearchingAnimationEnabled = true
        activateGoozeButton.setTitle(viewModel.searchingButtonTitle.uppercased(), for: .normal)
        activateGoozeButton.isEnabled = false
    }

    func showSearchResultsScene() {
        isSearchingAnimationEnabled = false
        activateGoozeButton.isHidden = false

        activateGoozeButton.isEnabled = true
        activateGoozeButton.setTitle(viewModel.allResultsButtonTitle.uppercased(), for: .normal)
        activateGoozeButton.reactive.pressed = showResultsListAction

        showBalloons()
    }

    func showAllResultsScene() {
        hideBalloons()

        usersList.onDismiss = { [weak self] in
            self?.usersList.onDismiss = nil
            self?.scene = .searchResults
        }

        usersList.users = viewModel.userResults.value
        usersList.show() 

        usersList.actionButton.setTitle(viewModel.otherResultsButtonTitle.uppercased(), for: .normal)
        usersList.actionButton.reactive.pressed = showOtherResultsListAction
    }

    func showOtherResultsListScene() {
        usersList.users = viewModel.userOtherResults.value
        usersList.actionButton.setTitle(viewModel.backButtonTitle.uppercased(), for: .normal)
        usersList.actionButton.reactive.pressed = showResultsListAction
        GZEAlertService.shared.showTopAlert(text: viewModel.othersResultsWarning)
    }
    
    func observeRequests() {
        if (disposeRequestsObserver == nil) {
            disposeRequestsObserver = GZEDatesService.shared
                .receivedRequests.signal.observeValues
                {[weak self] receivedRequests in
                    guard let this = self else {return}

                    log.debug("receivedRequests updated: \(receivedRequests)")
                    this.viewModel.userResults.value = receivedRequests
                    this.usersList.users = this.viewModel.userResults.value
                    this.updateBalloons()

                    if this.scene == .requestResults {
                        this.showBalloons()
                    }
            }
        }
    }

    // MARK: - Deinitializers
    deinit {
        disposeRequestsObserver?.dispose()
        disposeRequestsObserver = nil
        mapView.delegate = nil
        log.debug("\(self) disposed")
    }
}
