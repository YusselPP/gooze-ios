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
import PPBadgeView
import SwiftOverlays
import enum Result.NoError

class GZEActivateGoozeViewController: UIViewController, MKMapViewDelegate, GZEDismissVCDelegate {

    let segueToProfile = "segueToProfile"
    let segueToMyProfile = "segueToMyProfile"
    let segueToChats = "segueToChats"
    let segueToTips = "segueToTips"
    let segueToRatings = "segueToRatings"
    let segueToPayment = "segueToPayment"
    let segueToBalance = "segueToBalance"
    let segueToHelp = "segueToHelp"

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

        var isRequestResults: Bool {
            return (
                self == .requestResults ||
                self == .requestResultsList ||
                self == .requestOtherResultsList
            )
        }
    }
    var scene = Scene.search {
        didSet {
            if isViewLoaded {
                handleSceneChanged()
            }
        }
        willSet {
            if isViewLoaded {
                self.previousScene = self.scene
            }
        }
    }
    var previousScene: Scene?

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

    var isInitialPositionSet = false

    let (shown, shownObs) = Signal<Bool, NoError>.pipe()
    let sceneProperty = MutableProperty<Scene>(.search)

    var sliderPostfix = "km"
    var sliderStep: Float = 1

    var userBalloons = [GZEUserBalloon]()
    var tappedUserBaloon: GZEUserBalloon?
    let dateRequest = MutableProperty<GZEDateRequest?>(nil)

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

    @IBOutlet weak var mapViewContainer: UIView!
    var mapView: MKMapView!
    let isUserInteractionEnabled = MutableProperty<Bool>(false)

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

        self.shownObs.send(value: true)

        if let authorizationMessage = locationService.requestAuthorization() {
            GZEAlertService.shared.showBottomAlert(text: authorizationMessage)
        }

        let overlay = SwiftOverlays.showCenteredWaitOverlay(self.mapViewContainer)
        overlay.backgroundColor = .clear
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
            self?.initMapKit()
            overlay.removeFromSuperview()
        }

        if self.shouldRestartSearchingAnmiation {
            self.shouldRestartSearchingAnmiation = false
            self.isSearchingAnimationEnabled = true
        }

        if let mode = self.viewModel.mode.value {
            GZEChatService.shared.updateUnreadMessages(mode: mode)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.shownObs.send(value: false)

        if self.isSearchingAnimationEnabled {
            self.shouldRestartSearchingAnmiation = true
            self.isSearchingAnimationEnabled = false
        }

        self.deinitMapKit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupInterfaceObjects() {
        navigationItem.rightBarButtonItem = GZEExitAppButton.shared
        navIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(centerMapToUserLocation)))

        backButton.onButtonTapped = {[weak self] in
            self?.backButtonTapped($0)
        }

        setupMenu()

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

        self.containerView.addSubview(self.usersList)
        self.view.leadingAnchor.constraint(equalTo: self.usersList.leadingAnchor, constant: -20).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.usersList.trailingAnchor, constant: 20).isActive = true
        self.topLayoutGuide.bottomAnchor.constraint(equalTo: self.usersList.topAnchor, constant: -20).isActive = true
        self.bottomLayoutGuide.topAnchor.constraint(equalTo: self.usersList.bottomAnchor, constant: 20).isActive = true
    }

    func setupBindings() {

        self.shown.signal
            .combineLatest(
                with: self.sceneProperty.signal
            )
            .flatMap(.latest){
                (shown, scene) -> Signal<GZESocket.Event, NoError> in

                log.debug("shown: \(shown), scene: \(scene)")

                guard
                    let dateSocket = GZEDatesService.shared.dateSocket,
                    shown == true &&
                    scene.isRequestResults
                else {
                    return Signal.never
                }

                return dateSocket
                    .socketEventsEmitter
                    .signal
                    .skipNil()
                    .filter { $0 == .authenticated }
            }
            .observeValues {[weak self] _ in
                log.debug("socket auth event received")
                guard let this = self else {return}
                this.findUnrespondedRequests()
            }

        self.shown.signal
            .combineLatest(
                with: self.sceneProperty.signal
            )
            .flatMap(.latest){
                (shown, scene) -> Signal<GZEDateRequest, NoError> in

                log.debug("shown: \(shown), scene: \(scene)")

                guard shown == true && scene.isRequestResults else {
                    return Signal.never
                }

                return (
                    GZEDatesService.shared
                        .lastReceivedRequest
                        .signal
                        .skipNil()
                )
            }
            .observeValues{
                [weak self] receivedRequest in
                log.debug("dateRequest received: \(receivedRequest.id)")
                guard let this = self else {return}
                this.viewModel.userResults.value.upsert(receivedRequest){
                    guard let dateRequest = $0 as? GZEDateRequest else {return false}
                    return dateRequest.id == receivedRequest.id
                }
                this.updateReceivedRequests(this.viewModel.userResults.value)
            }

        viewModel.messagesCount
            .map{$0.reduce(0, {$0 + $1.value})}
            .producer.startWithValues {
                GZEMenuMain.shared.navButton.pp_addBadge(withNumber: $0)
                GZEMenuMain.shared.chatButton.pp_addBadge(withNumber: $0)
            }

        viewModel.sliderValue <~ topSlider.reactive.values
        topSlider.reactive.value <~ viewModel.sliderValue

        dateRequest.signal.skipNil().skipRepeats().observeValues{[weak self] dateRequest in
            guard let this = self, let tappedBalloon = this.tappedUserBaloon else {return}

            let (_, index) = this.viewModel.userResults.value.upsert(dateRequest){$0===tappedBalloon.userConvertible}
            if index < this.userBalloons.count {
                this.userBalloons[index].userConvertible = dateRequest
            }
            if this.scene == .resultsList || this.scene == .requestResultsList {
                this.usersList.users.upsert(dateRequest){$0===tappedBalloon.userConvertible}
                tappedBalloon.userConvertible = dateRequest
            }
        }

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

    func setBackButton() {
        navigationItem.setLeftBarButton(backButton, animated: false)
    }

    func setMenuButton() {
        navigationItem.setLeftBarButton(GZEMenuMain.shared.navButton, animated: false)
    }

    func setupMenu() {
        GZEMenuMain.shared.controller = self
        GZEMenuMain.shared.containerView = containerView
    }


    func updateBalloons() {
        hideBalloons()
        let users = viewModel.userResults.value
        log.debug(users)
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
        guard
            (self.previousScene == nil || self.previousScene == .search) && self.scene == .activate ||
            (self.previousScene == nil || self.previousScene == .activate) && self.scene == .search
        else {
                return
        }

        if self.scene == .activate {
            sliderPostfix = "hrs"
            sliderStep = 0.5

            topSlider.maximumValue = 3
            topSlider.value = 1
            viewModel.sliderValue.value = 2
        } else {
            sliderPostfix = "kms"
            sliderStep = 1

            topSlider.maximumValue = 50
            topSlider.value = 1
            viewModel.sliderValue.value = 25
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
            tappedUserBaloon = userBalloon
            dateRequest.value = tappedUserBaloon?.userConvertible as? GZEDateRequest
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
                findUnrespondedRequests()

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

    // MARK: - Mapkit

    func initMapKit() {
        let mapService = GZEMapService.shared
        self.mapView = mapService.mapView

        mapService.disposables.append(
            mapService.centerCoordinate.signal
                .skipNil()
                .observeValues{[weak self] coord in
                    self?.viewModel.mapCenterLocation.value = coord
                }
        )

        mapService.disposables.append(
            mapService.userLocation.signal
                .skipNil()
                .take{[weak self] _ in
                    log.debug("take while: \(!(self?.isInitialPositionSet ?? true))")
                    guard let this = self else {return false}
                    return !this.isInitialPositionSet
                }
                .observeValues{[weak self] location in
                    log.debug("userLocation: \(location)")
                    self?.isInitialPositionSet = true
                    self?.centerMapToUserLocation()
            }
        )

        self.mapView.delegate = mapService
        self.mapView.showsUserLocation = true
        self.mapView.setCenter(self.viewModel.mapCenterLocation.value, animated: false)

        mapService.disposables.append(
            self.mapView.reactive.isUserInteractionEnabled <~ self.isUserInteractionEnabled
        )

        // Map Constraints
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        self.mapViewContainer.addSubview(self.mapView)
        self.mapViewContainer.topAnchor.constraint(equalTo: self.mapView.topAnchor).isActive = true
        self.mapViewContainer.bottomAnchor.constraint(equalTo: self.mapView.bottomAnchor).isActive = true
        self.mapViewContainer.leadingAnchor.constraint(equalTo: self.mapView.leadingAnchor).isActive = true
        self.mapViewContainer.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor).isActive = true
    }

    func deinitMapKit() {
        GZEMapService.shared.cleanMap()
        self.mapView = nil
    }

    func centerMapToUserLocation() {
        if let authorizationMessage = locationService.requestAuthorization() {
            GZEAlertService.shared.showBottomAlert(text: authorizationMessage)
        } else {
            mapView.setRegion(MKCoordinateRegionMake(mapView.userLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01)), animated: true)
            GZEMapService.shared.centerCoordinate.value = mapView.userLocation.coordinate
        }
    }

    // MARK: Dismiss delegate
    func onDismissTapped(_ vc: UIViewController) {
        if vc.isKind(of: GZEPaymentMethodsViewController.self) {
           vc.previousController(animated: true)
        } else if vc.isKind(of: GZEHelpViewController.self) {
            vc.previousController(animated: true)
        } else if vc.isKind(of: GZEBalanceViewController.self) {
            vc.previousController(animated: true)
        }
    }


     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == segueToProfile {

            if let pageViewController = segue.destination as? GZEProfilePageViewController {
                if let user = sender as? GZEUser {

                    pageViewController.profileVm = GZEProfileUserInfoViewModelReadOnly(user: user, dateRequest: dateRequest)
                    pageViewController.galleryVm = GZEGalleryViewModelReadOnly(user: user, dateRequest: dateRequest)
                    pageViewController.ratingsVm = GZERatingsViewModelReadOnly(user: user, dateRequest: dateRequest)

                    if
                        scene == .activate ||
                        scene == .requestResults ||
                        scene == .requestResultsList ||
                        scene == .requestOtherResultsList
                    {
                        pageViewController.profileVm.mode = .request
                        pageViewController.galleryVm.mode = .request
                        pageViewController.ratingsVm.mode = .request
                    }
                } else {
                    log.error("Unable to obatain the user from segue sender")
                }
            } else {
                log.error("Unable to cast segue.destination as? GZEProfilePageViewController")
            }
        } else if segue.identifier == segueToMyProfile {
            prepareMyProfileSegue(segue.destination)
        } else if segue.identifier == segueToChats {
            prepareChatSegue(segue.destination)
        } else if segue.identifier == segueToPayment {
            preparePaymentSegue(segue.destination)
        } else if segue.identifier == segueToHelp {

            GZEHelpViewController.prepareHelpView(
                presenter: self,
                viewController: segue.destination,
                vm: sender
            )
        } else if segue.identifier == segueToBalance {

            GZEBalanceViewController.prepareView(
                presenter: self,
                viewController: segue.destination,
                vm: sender
            )
        }
     }

    @IBAction func unwindToActivateGooze(segue: UIStoryboardSegue) {
        log.debug("segue.identifier: \(unwindToActivateGooze)")
        if segue.identifier == "unwindToActivateGooze" {
            switch scene {
            case .activate,
                 .requestResults,
                 .requestResultsList,
                 .requestOtherResultsList:
                scene = .activate
            case .search,
                 .searching,
                 .searchResults,
                 .resultsList,
                 .otherResultsList:
                scene = .search
            }
        }
    }

    func prepareMyProfileSegue(_ vc: UIViewController) {
        guard let vc = vc as? GZEProfilePageViewController else {
            log.error("Unable to cast segue.destination as? GZEProfilePageViewController")
            return
        }

        guard let user = GZEAuthService.shared.authUser else {
            log.error("Auth user not found")
            return
        }

        vc.profileVm = GZEProfileUserInfoViewModelMe(user)
        vc.ratingsVm = GZERatingsViewModelMe(user)
        vc.galleryVm = GZEGalleryViewModelMe(user)
    }

    func prepareChatSegue(_ vc: UIViewController) {
        if let vc = vc as? GZEChatsViewController {
            let mode: GZEChatViewMode
            if
                scene == .activate ||
                scene == .requestResults ||
                scene == .requestResultsList ||
                scene == .requestOtherResultsList
            {
                mode = .gooze
            } else {
                mode = .client
            }
            vc.viewModel = self.viewModel.getChatsViewModel(mode)

        } else {
            log.error("Unable to cast segue.destination as? GZEChatsViewController")
        }
    }

    func preparePaymentSegue(_ vc: UIViewController) {
        if let vc = vc as? GZEPaymentMethodsViewController {

            vc.viewModel = self.viewModel.paymentViewModel
            vc.dismissDelegate = self

        } else {
            log.error("Unable to cast segue.destination as? GZEChatsViewController")
        }
    }

    // MARK: - Scenes
    func handleSceneChanged() {
        hideAll()
        GZEAlertService.shared.dismissBottomAlert()
        GZEAlertService.shared.dismissTopAlert()
        self.sceneProperty.value = self.scene
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
        viewModel.mode.value = .gooze

        topControls.isHidden = false
        topControlsBackground.isHidden = false
        activateGoozeButton.isHidden = false

        setupSlider()
        setMenuButton()
        hideBalloons()

        GZEMenuMain.shared.switchModeGoozeButton?.setTitle(GZEMenuMain.shared.menuItemTitleSearchGooze, for: .normal)

        isUserInteractionEnabled.value = true
        isSearchingAnimationEnabled = false
        shouldRestartSearchingAnmiation = false
        activateGoozeButton.isEnabled = true

        activateGoozeButton.setTitle(viewModel.activateButtonTitle.uppercased(), for: .normal)
        activateGoozeButton.reactive.pressed = activateGoozeAction
        //stopObservingRequests()
        //isObservingRequests = false
    }

    func showRequestResultsScene() {
        isUserInteractionEnabled.value = false
        isSearchingAnimationEnabled = true
        activateGoozeButton.isHidden = false

        setBackButton()

        activateGoozeButton.setTitle(viewModel.allResultsButtonTitle.uppercased(), for: .normal)
        activateGoozeButton.reactive.pressed = showRequestResultsListAction

        showBalloons()
    }

    func showRequestResultsListScene() {
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
        viewModel.mode.value = .client
        topControls.isHidden = false
        topControlsBackground.isHidden = false
        activateGoozeButton.isHidden = false

        setupSlider()
        setMenuButton()
        GZEMenuMain.shared.switchModeGoozeButton?.setTitle(GZEMenuMain.shared.menuItemTitleBeGooze, for: .normal)

        isUserInteractionEnabled.value = true
        isSearchingAnimationEnabled = false
        shouldRestartSearchingAnmiation = false

        viewModel.searchLimit.value = MAX_RESULTS

        activateGoozeButton.isEnabled = true
        activateGoozeButton.setTitle(viewModel.searchButtonTitle.uppercased(), for: .normal)
        activateGoozeButton.reactive.pressed = searchGoozeAction

        hideBalloons()
    }

    func showSearchingScene() {
        isUserInteractionEnabled.value = false
        activateGoozeButton.isHidden = false

        setBackButton()

        isSearchingAnimationEnabled = true
        activateGoozeButton.setTitle(viewModel.searchingButtonTitle.uppercased(), for: .normal)
        activateGoozeButton.isEnabled = false
    }

    func showSearchResultsScene() {
        isSearchingAnimationEnabled = false
        shouldRestartSearchingAnmiation = false
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

    func findUnrespondedRequests() {
        GZEDatesService.shared.findUnrespondedRequests()
            .start {[weak self] event in
                log.debug("event received: \(event)")
                guard let this = self else {return}
                switch event {
                case .value(let dateRequests):
                    this.updateReceivedRequests(dateRequests)
                case .failed(let error):
                    this.onError(error)
                default: break
                }
            }
    }

    func onError(_ error: GZEError) {
        GZEAlertService.shared.showBottomAlert(text: error.localizedDescription)
    }

    func updateReceivedRequests(_ receivedRequests: [GZEUserConvertible]) {
        // TODO: divide in two list: if request.sender.rate <= 0 others else normalresults
        //       if scene == .otherResults show others list else show normalResultsList

        log.debug("receivedRequests updated: \(receivedRequests)")
        self.viewModel.userResults.value = receivedRequests
        self.usersList.users = self.viewModel.userResults.value
        self.updateBalloons()

        if self.scene == .requestResults {
            self.showBalloons()
        }
    }

    // MARK: - Deinitializers
    deinit {
        GZEMenuMain.shared.menu.close(animated: false)
        log.debug("\(self) disposed")
    }
}
