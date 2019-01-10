//
//  GZESignUpPhotoViewController.swift
//  Gooze
//
//  Created by Yussel Paredes on 10/26/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result
import ALCameraViewController
import Photos
import SwiftOverlays

class GZESignUpPhotoViewController: UIViewController, UIScrollViewDelegate, GZEDismissVCDelegate, GZENextVCDelegate {

    let segueToPayment = "segueToPayment"
    let segueToRegisterPayPal = "segueToRegisterPayPal"
    
    var blur: GZEBlur?

    var viewModel: GZEUpdateProfileViewModel!

    var saveProfileAction: CocoaAction<UIButton>!
    var saveSearchAction: CocoaAction<UIButton>!
    var saveGalleryAction: CocoaAction<UIButton>!

    var selectedThumbnail: MutableProperty<UIImage?>?
    var selectedThumbnailRequest: MutableProperty<URLRequest?>?

    var photoImageViews: [UIImageView] = []

    var mode: Mode = .editProfilePic

    enum Mode {
        case editProfilePic
        case editGalleryPic
    }

    var scene: Scene! {
        didSet {
            showCurrentScene()
        }
    }

    enum Scene {
        case profilePic
        case searchPic

        case cameraOrReel
        case blur
        case camera
        case library

        case gallery
    }

    var cropArea: CGRect {
        var overlay: UIView

        if scene == .profilePic {
            overlay = profileOverlay
        } else if scene == .searchPic {
            overlay = searchOverlay
        } else {
            overlay = overlayView
        }

        let imageFrame = mainImageView.imageFrame()
        let imageScale = 1/mainImageView.imageScale()
        let x = (backScrollView.contentOffset.x + overlay.frame.origin.x - imageFrame.origin.x) * imageScale
        let y = (backScrollView.contentOffset.y + overlay.frame.origin.y - imageFrame.origin.y) * imageScale
        let width = overlay.frame.size.width * imageScale
        let height = overlay.frame.size.height * imageScale

        let resultArea = CGRect(x: x, y: y, width: width, height: height)

        log.debug("original image size: \(String(describing: mainImageView.image?.size))")
        log.debug("image scale: \(imageScale)")
        log.debug("backScrollView.contentOffset: \(backScrollView.contentOffset)")
        log.debug("profileOverlay.frame: \(profileOverlay.frame)")
        log.debug("imageFrame: \(imageFrame)")
        log.debug("resultArea: \(resultArea)")

        return resultArea
    }

    var originalImage: UIImage?

    var nextButton = GZENextUIBarButtonItem()
    var backButton = GZEBackUIBarButtonItem()
    var undoButton = GZENavButton()

    @IBOutlet weak var backScrollView: UIScrollView! {
        didSet {
            backScrollView.delegate = self
        }
    }
    @IBOutlet weak var dblCtrlView: GZEDoubleCtrlView!

    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var searchOverlay: UIView!
    @IBOutlet weak var profileOverlay: UIView!
    @IBOutlet weak var cameraOrReelView: UIView!
    @IBOutlet weak var blurEffectView: UIView!
    @IBOutlet weak var editButtonView: UIView!
    @IBOutlet weak var photoThumbnailsView: UIView!
    @IBOutlet weak var blurControlsView: UIView!

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var photoImageView1: UIImageView!
    @IBOutlet weak var photoImageView2: UIImageView!
    @IBOutlet weak var photoImageView3: UIImageView!
    @IBOutlet weak var photoImageView4: UIImageView!

    @IBOutlet weak var bottomRightButton: UIButton!
    @IBOutlet weak var editButton1: UIButton!
    @IBOutlet weak var editButton2: UIButton!
    @IBOutlet weak var editButton3: UIButton!
    @IBOutlet weak var editButton4: UIButton!
    @IBOutlet weak var showBlurButton: UIButton!
    @IBOutlet weak var applyBlurButton: UIButton!

    @IBOutlet weak var photoLabel: UILabel!

    @IBOutlet weak var blurSlider: UISlider!

    @IBOutlet weak var libraryCollectionView: GZELibraryCollectionView!

    // Landscape/Portrait layout constraints
    @IBOutlet weak var superviewTrailingImageContainerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewTopImageContainerBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var viewLeadingSuperviewLeadingConstrint: NSLayoutConstraint!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var imageContainerTrailingViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var superViewBottomImageContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var superviewTopViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewWidthConstraint: NSLayoutConstraint!


    @IBOutlet weak var searchOverlayLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchOverlayTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchOverlayTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchOverlayBottomConstraint: NSLayoutConstraint!

    // Method weak references
    var onEventPtr: ((Event<GZEUser,GZEError>) -> Void)!
    var onActionTriggered: ((UIButton) -> Void)!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        createWeakMethods()
        setupInterfaceObjects()
        setupBindings()

        switch mode {
        case .editGalleryPic:
            scene = .gallery
            //editButton1.sendActions(for: .touchUpInside)
            selectTumbnail(tag: 0)
        case .editProfilePic:
            scene = .cameraOrReel
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setLayout()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        log.debug("viewDidLayoutSubviews")
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        log.debug("View Will Transition to size: \(size)")

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.overlayView.alpha = 0
        }

        if size.width > size.height {
            setLayout(.landscapeLeft)
        } else {
            setLayout(.portrait)
        }

        coordinator.animate(alongsideTransition: nil) { [unowned self] _ in
            log.debug("View did Transition to size: \(size)")
            log.debug("Status bar landscape? \(UIApplication.shared.statusBarOrientation.isLandscape)")
            log.debug("Status bar portrait? \(UIApplication.shared.statusBarOrientation.isPortrait)")


            self.setZoomScale()
            self.setScrollInsets()
            self.backScrollView.centerContent(animated: true)

            self.setOverlay()
            self.blur?.draw()

            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.overlayView.alpha = 0.5
            }
        }
        super.viewWillTransition(to: size, with: coordinator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Setup
    func createWeakMethods() {
        onActionTriggered =  { [weak self] btn in
            self?.actionTriggerHandler(btn)
        }
        onEventPtr =  { [weak self] evt in
            self?.onEvent(event: evt)
        }
    }

    func setupInterfaceObjects() {
        setupBlur()
        setupDblCtrlView()

        self.libraryCollectionView.onSelectionComplete = {
            [weak self] asset in
            self?.fetchImage(asset: asset)
        }

        let image = #imageLiteral(resourceName: "undo-icon")
        undoButton.button.frame = CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height)
        undoButton.button.setImage(image, for: .normal)

        backButton.onButtonTapped =  { [weak self] btn in  self?.backButtonTapped(btn) }
        nextButton.onButtonTapped =  { [weak self] btn in  self?.nextButtonTapped(btn) }
        undoButton.onButtonTapped = { [weak self] in self?.undoButtonTapped($0) }
        navigationItem.hidesBackButton = true

        photoImageViews.append(photoImageView1)
        photoImageViews.append(photoImageView2)
        photoImageViews.append(photoImageView3)
        photoImageViews.append(photoImageView4)

        editButton1.tag = 0
        editButton2.tag = 1
        editButton3.tag = 2
        editButton4.tag = 3

        editButton1.addTarget(self, action: #selector(thumbnailTapped(_:)), for: .touchUpInside)
        editButton2.addTarget(self, action: #selector(thumbnailTapped(_:)), for: .touchUpInside)
        editButton3.addTarget(self, action: #selector(thumbnailTapped(_:)), for: .touchUpInside)
        editButton4.addTarget(self, action: #selector(thumbnailTapped(_:)), for: .touchUpInside)

        editButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editButtonViewTapped(_:))))
    }

    func setupBindings() {
        // mainImageView.reactive.image <~ viewModel.mainImage
        viewModel.mainImage.signal.observeValues { [weak self] in
            guard let this = self else {return}
            this.mainImageView.image = $0
            //this.setScrollInsets()
            //this.setZoomScale()
            //this.backScrollView.centerContent(animated: true)
        }

        mainImageView.reactive.imageUrlRequestLoading <~ viewModel.mainImageRequest

        for (index, imageView) in photoImageViews.enumerated() {
            if index < viewModel.thumbnails.count {
                imageView.tag = index
                imageView.reactive.image <~ viewModel.thumbnails[index]
                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(thumbnailImageTapped(_:))))
            }

            if index < viewModel.thumbnailsRequest.count {
                imageView.reactive.imageUrlRequestLoading <~ viewModel.thumbnailsRequest[index]
            }
        }


        saveProfileAction = CocoaAction(viewModel.saveProfilePicAction, onActionTriggered)
        saveSearchAction = CocoaAction(viewModel.saveSearchPicAction, onActionTriggered)
        saveGalleryAction = CocoaAction(viewModel.savePhotosAction, onActionTriggered)


        viewModel.saveProfilePicAction.events.observeValues(onEventPtr)
        viewModel.saveSearchPicAction.events.observeValues(onEventPtr)
        viewModel.savePhotosAction.events.observeValues(onEventPtr)
    }



    func setupBlur() {
        showBlurButton.setTitle(viewModel.blurButtonTitle, for: .normal)
        applyBlurButton.setTitle(viewModel.applyBlurButtonTitle, for: .normal)
        blurSlider.reactive.values.debounce(0.3, on: QueueScheduler.main).observeValues { [weak self] in
            self?.blur?.radius = $0
        }

        blurEffectView.layer.borderWidth = 1
        blurEffectView.layer.borderColor = UIColor.white.cgColor
        blurEffectView.layer.cornerRadius = blurEffectView.frame.size.width / 2

        blurEffectView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(blurPan(_:))))
        blurEffectView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(blurPinched(_:))))
    }

    func setupDblCtrlView() {
        let cameraButton = UIButton()
        cameraButton.setImage(#imageLiteral(resourceName: "camera-white-icon"), for: .normal)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.addTarget(self, action: #selector(showCamera), for: .touchUpInside)
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(cameraButton)
        topView.topAnchor.constraint(equalTo: cameraButton.topAnchor).isActive = true
        topView.bottomAnchor.constraint(equalTo: cameraButton.bottomAnchor).isActive = true
        topView.centerXAnchor.constraint(equalTo: cameraButton.centerXAnchor).isActive = true
        cameraButton.widthAnchor.constraint(equalToConstant: 32.0).isActive = true

        let reelButton = UIButton()
        reelButton.setImage(#imageLiteral(resourceName: "movie-icon"), for: .normal)
        reelButton.translatesAutoresizingMaskIntoConstraints = false
        reelButton.addTarget(self, action: #selector(showLibrary), for: .touchUpInside)
        let botView = UIView()
        botView.translatesAutoresizingMaskIntoConstraints = false
        botView.addSubview(reelButton)
        botView.topAnchor.constraint(equalTo: reelButton.topAnchor).isActive = true
        botView.bottomAnchor.constraint(equalTo: reelButton.bottomAnchor).isActive = true
        botView.centerXAnchor.constraint(equalTo: reelButton.centerXAnchor).isActive = true
        reelButton.widthAnchor.constraint(equalToConstant: 32.0).isActive = true

        dblCtrlView.topCtrlView = topView
        dblCtrlView.bottomCtrlView = botView
        dblCtrlView.separatorWidth = 35

        dblCtrlView.topViewTappedHandler = { _ in
            cameraButton.sendActions(for: .touchUpInside)
        }
        dblCtrlView.bottomViewTappedHandler = { _ in
            reelButton.sendActions(for: .touchUpInside)
        }
    }

    // MARK: - Actions
    @IBAction func nextButtonTapped(_ sender: Any) {
        switch scene! {
        case .profilePic:
            let croppedImage = viewModel.mainImage.value?.crop(to: cropArea)
            viewModel.profilePic.value = croppedImage
            saveProfileAction.execute(sender)
        case .searchPic:
            let croppedImage = viewModel.mainImage.value?.crop(to: cropArea)
            viewModel.searchPic.value = croppedImage
            saveSearchAction.execute(sender)
        case .blur:
            blur?.disable()
            viewModel.mainImage.value = blur?.resultImage
            blur = nil
            switch mode {
            case .editProfilePic:
                scene = .profilePic
            case .editGalleryPic:
                selectedThumbnail?.value = viewModel.mainImage.value?.crop(to: cropArea)
                viewModel.mainImage.value = selectedThumbnail?.value
                setZoomScale()
                scene = .gallery
            }
        case .gallery:
            saveGalleryAction.execute(sender)
        case .library:
            scene = .blur
        default:
            break
        }
    }

    func backButtonTapped(_ sender: Any) {
        switch scene! {
        case .cameraOrReel:
            switch mode {
            case .editProfilePic: previousController(animated: true)
            case .editGalleryPic:
                scene = .gallery
            }
        case .profilePic:
            scene = .cameraOrReel
        case .searchPic:
            scene = .profilePic
        case .blur:
            blur?.disable()
            viewModel.mainImage.value = nil
            scene = .cameraOrReel
        case .gallery:
            previousController(animated: true)
        case .library:
            scene = .cameraOrReel
        default:
            break
        }
    }

    func undoButtonTapped(_ sender: Any) {
        switch scene! {
        case .blur:
            blur?.revert()
        default:
            break
        }
    }

    @objc func editButtonViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        if let view = gestureRecognizer.view {
            editPhotoButtonTapped(view)
        }
    }

    @IBAction func editPhotoButtonTapped(_ sender: Any) {
        scene = .cameraOrReel
        //showCamera()
    }

    @IBAction func addPhoto(_ sender: UIButton) {
        //showCamera()
        scene = .cameraOrReel
    }

    @objc func thumbnailImageTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        if let view = gestureRecognizer.view {
            thumbnailTapped(view)
        }
    }

    @IBAction func thumbnailTapped(_ sender: UIView) {
        selectTumbnail(tag: sender.tag)

        if selectedThumbnail?.value == nil && selectedThumbnailRequest?.value == nil {
            //showCamera()
            scene = .cameraOrReel
        }
    }

    func selectTumbnail(tag: Int) {
        selectedThumbnail = viewModel.thumbnails[tag]
        selectedThumbnailRequest = viewModel.thumbnailsRequest[tag]

        displaySelectedThumbanail()
    }

    func displaySelectedThumbanail() {
        if selectedThumbnail?.value != nil {
            viewModel.mainImage.value = selectedThumbnail?.value
        } else {
            viewModel.mainImageRequest.value = selectedThumbnailRequest?.value
        }
    }

    @IBAction func showBlurButtonTapped(_ sender: Any) {
        if blur != nil {
            if blur!.isEnabled {
                showBlur(false)
            } else {
                showBlur(true)
            }
        }
    }

    func showBlur(_ show: Bool) {
        guard let blur = blur else { return }
        if show {
            blurEffectView.transform = .identity
            blurEffectView.isHidden = false
            blur.enable()

            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.blurSlider.alpha = 1
                self?.applyBlurButton.alpha = 1
            }
        } else {
            blur.disable()
            blurEffectView.isHidden = true

            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.blurSlider.alpha = 0
                self?.applyBlurButton.alpha = 0
            }
        }
    }

    @IBAction func applyButtonTapped(_ sender: Any) {
        blur?.apply()
        showBlur(false)
    }

    @objc func blurPinched(_ gestureRecognizer: UIPinchGestureRecognizer) {

        guard gestureRecognizer.state == .began || gestureRecognizer.state == .changed else { return }

        guard gestureRecognizer.numberOfTouches > 1 else { return }
        

        guard let view = gestureRecognizer.view else {
            log.debug("Gesture doesn't have a view")
            return
        }

        let location1 = gestureRecognizer
            .location(ofTouch: 0, in: view)
        let location2 = gestureRecognizer
            .location(ofTouch: 1, in: view)

        //log.debug("touch 1 location: \(location1)")
        //log.debug("touch 2 location: \(location2)")


        let scale = gestureRecognizer.scale
        var xScale: CGFloat = 1
        var yScale: CGFloat = 1

        let x1 = location1.x
        let x2 = location2.x
        let y1 = location1.y
        let y2 = location2.y

        if x1 == x2 {
            // Catch perfect vertical line to avoid div by Zero
            yScale = scale
        } else {
            // Calc line slope
            let slope = abs((y1 - y2) / (x1 - x2))

            if slope < 0.5 {
                // Horizontal scaling range
                xScale = scale
            } else if slope < 1.5 {
                // Diagonal scaling range
                xScale = scale
                yScale = scale
            } else {
                // Vertical scaling range
                yScale = scale
            }
        }

        let transform = view.transform.scaledBy(x: xScale, y: yScale)

        guard transform.a >= 0.6 && transform.d >= 0.6 else {
            log.debug("Reached min size")
            return
        }

        view.transform = transform
        gestureRecognizer.scale = 1

        blur?.draw()
    }

    @objc func blurPan(_ gestureRecognizer: UIPanGestureRecognizer) {

        guard gestureRecognizer.state == .began || gestureRecognizer.state == .changed else { return }

        guard let view = gestureRecognizer.view else {
            log.debug("Gesture doesn't have a view")
            return
        }

        let containerView: UIView = imageContainerView
        let translation = gestureRecognizer.translation(in: containerView)

        var transform = view.transform.translatedBy(x: translation.x, y: translation.y)

        // limits
        let viewCenter = view.center
        transform.tx = min(max(transform.tx, -viewCenter.x), viewCenter.x)
        transform.ty = min(max(transform.ty, -viewCenter.y), viewCenter.y)

        // log.debug("new view transform: \(transform)")
        view.transform = transform
        gestureRecognizer.setTranslation(CGPoint.zero, in: containerView)

        blur?.draw()
    }

    @objc func showCamera() {
        let cameraViewController = CameraViewController(croppingParameters: CroppingParameters(isEnabled: false, allowResizing: false, allowMoving: false)) { [weak self] image, asset in

            log.debug("camera controller handler")

            guard let this = self else {
                log.error("self was dispossed before calling handler")
                return
            }

            guard let image = image else {
                log.debug("Empty image received")
                this.dismiss(animated: true, completion: nil)
                return
            }

            guard let compressedImage = GZEImageHelper.compressImage(image) else {
                log.error("Unable to compress the image")
                this.dismiss(animated: true, completion: nil)
                return
            }

            this.viewModel.mainImage.value = compressedImage
            this.originalImage = compressedImage

            this.blur = GZEBlur(image: compressedImage, blurEffectView: this.blurEffectView, resultImageView: this.mainImageView, scrollView: this.backScrollView)

            this.scene = .blur
            this.dismiss(animated: true, completion: nil)
        }

        present(cameraViewController, animated: true, completion: nil)
    }

    @objc func showLibrary() {
        scene = .library
    }

    func fetchImage(asset: PHAsset?) {
        if let asset = asset {
            let overlay = SwiftOverlays.showCenteredWaitOverlay(imageContainerView)
            overlay.backgroundColor = .clear
            _ = SingleImageFetcher()
                .setAsset(asset)
                .onSuccess { [weak self] image in
                    log.debug("success")
                    overlay.removeFromSuperview()

                    guard let this = self else {
                        log.error("self was dispossed before calling handler")
                        return
                    }

                    guard let compressedImage = GZEImageHelper.compressImage(image) else {
                        log.error("Unable to compress the image")
                        return
                    }

                    this.viewModel.mainImage.value = compressedImage
                    this.originalImage = compressedImage

                    this.blur = GZEBlur(image: compressedImage, blurEffectView: this.blurEffectView, resultImageView: this.mainImageView, scrollView: this.backScrollView)

                    // this.scene = .blur
                }
                .onFailure {error in
                    overlay.removeFromSuperview()
                    log.error(error)
                }
                .fetch()
        } else {
            log.error("nil asset")
        }
    }

    func setLayout(_ aOrientation: UIInterfaceOrientation? = nil) {
        log.debug("Setting layout..")
        log.debug("controller view frame: \(view.frame)")
        log.debug("Image container frame: \(imageContainerView.frame)")
        log.debug("Search frame: \(searchOverlay.frame)")
        var orientation: UIInterfaceOrientation

        if aOrientation != nil {
            orientation = aOrientation!
        } else {
            orientation = UIApplication.shared.statusBarOrientation
        }

        if orientation.isLandscape {
            setLandscapeLayout()
        } else {
            setPortraitLayout()
        }

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })

        self.setSearchOverlayConstraints()

        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })

        log.debug("Layout set")
        log.debug("Image container frame: \(imageContainerView.frame)")
        log.debug("Search frame: \(searchOverlay.frame)")
    }

    func setPortraitLayout() {
        imageContainerTrailingViewLeadingConstraint.isActive = false
        superViewBottomImageContainerBottomConstraint.isActive = false
        superviewTopViewTopConstraint.isActive = false
        bottomViewWidthConstraint.isActive = false

        superviewTrailingImageContainerTrailingConstraint.isActive = true
        viewTopImageContainerBottomConstraint.isActive = true
        viewLeadingSuperviewLeadingConstrint.isActive = true
        bottomViewHeightConstraint.isActive = true
        log.debug("Portrait layout set")
    }

    func setLandscapeLayout() {
        superviewTrailingImageContainerTrailingConstraint.isActive = false
        viewTopImageContainerBottomConstraint.isActive = false
        viewLeadingSuperviewLeadingConstrint.isActive = false
        bottomViewHeightConstraint.isActive = false

        imageContainerTrailingViewLeadingConstraint.isActive = true
        superViewBottomImageContainerBottomConstraint.isActive = true
        superviewTopViewTopConstraint.isActive = true
        bottomViewWidthConstraint.isActive = true
        log.debug("Landscape layout set")
    }

    func setSearchOverlayConstraints() {
        log.debug("Image container frame: \(imageContainerView.frame)")
        if imageContainerView.bounds.width < imageContainerView.bounds.height {
            searchOverlayTopConstraint.isActive = false
            searchOverlayBottomConstraint.isActive = false

            searchOverlayLeadingConstraint.isActive = true
            searchOverlayTrailingConstraint.isActive = true
        } else {
            searchOverlayLeadingConstraint.isActive = false
            searchOverlayTrailingConstraint.isActive = false

            searchOverlayTopConstraint.isActive = true
            searchOverlayBottomConstraint.isActive = true
        }
    }

    func setOverlay() {
        log.debug("searchOverlay frame: \(searchOverlay.frame)")
        let path = CGMutablePath()

        if scene == .profilePic {
            path.addRect(profileOverlay.frame)
        } else if scene == .searchPic {
            path.addArc(center: searchOverlay.center, radius: min(searchOverlay.frame.width, searchOverlay.frame.height)/2, startAngle: 0.0, endAngle: 2 * 3.14, clockwise: false)
        } else {
            overlayView.isHidden = true
            return
        }

        overlayView.isHidden = false

        path.addRect(overlayView.bounds)

        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.white.cgColor
        maskLayer.path = path;
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd

        overlayView.layer.mask = maskLayer
    }

    // MARK: - CocoaAction
    func onEvent(event: Event<GZEUser, GZEError>) {
        log.debug("Action event received: \(event)")
        hideLoading()

        switch event {
        case .value(let user):
            switch scene! {
            case .profilePic:
                onSaveProfileSuccess(user: user)
            case .searchPic:
                onSaveSearchSuccess(user: user)
            case .gallery:
                onSaveGallerySuccess(user: user)
            default:
                break;
            }
        case .failed(let err):
            onError(err: err)
        default:
            break
        }
    }

    func onSaveProfileSuccess(user: GZEUser) {
        log.debug("Profile pic saved")
        scene = .searchPic

        log.debug("profile pic response user \(String(describing: user.toJSON()))")
        log.debug("viewModel.user \(String(describing: viewModel.user.toJSON()))")
    }

    func onSaveSearchSuccess(user: GZEUser) {
        log.debug("Search pic saved")
        previousController(animated: true)
    }

    func onSaveGallerySuccess(user: GZEUser) {
        log.debug("Gallery saved")
        showChooseModeController()
    }

    func actionTriggerHandler(_ sender: UIButton) {
        showLoading()
    }

    func onError(err: GZEError) {
        GZEAlertService.shared.showBottomAlert(text: err.localizedDescription)
    }

    // MARK: - Scenes
    func showCurrentScene() {

        hideAll()

        GZEAlertService.shared.dismissBottomAlert()

        switch scene! {
        case .cameraOrReel:
            showCameraOrReelScene()
        case .library:
            showLibraryScene()
        case .blur:
            showBlurScene()
        case .profilePic:
            showProfileScene()
        case .searchPic:
            showSearchScene()
        case .gallery:
            showGalleryScene()
        default:
            showCameraOrReelScene()
        }
    }

    func hideAll() {
        backScrollView.isHidden = true
        overlayView.isHidden = true
        cameraOrReelView.isHidden = true
        blurControlsView.isHidden = true
        photoThumbnailsView.isHidden = true
        photoLabel.isHidden = true
        blurEffectView.isHidden = true
        dblCtrlView.isHidden = true
        libraryCollectionView.isHidden = true

        bottomRightButton.isHidden = true
        editButtonView.isHidden = true
    }

    func showGalleryScene() {
        backScrollView.isHidden = false
        photoThumbnailsView.isHidden = false
        bottomRightButton.isHidden = false
        showBackButton(true)
        showNextButton(false)

        // viewModel.mainImage.value = selectedThumbnail?.value
        displaySelectedThumbanail()

        editButtonView.isHidden = false
        bottomRightButton.setTitle(viewModel.saveButtonTitle.uppercased(), for: .normal)
    }

    func showCameraOrReelScene() {
        // cameraOrReelView.isHidden = false
        dblCtrlView.isHidden = false
        showBackButton(true)
        showNextButton(false)
    }

    func showLibraryScene() {
        backScrollView.isHidden = false
        libraryCollectionView.isHidden = false
        bottomRightButton.isHidden = false
        libraryCollectionView.fetchImages()

        viewModel.mainImage.value = nil

        showBackButton(true)
        showNextButton(true)

        bottomRightButton.setTitle(viewModel.nextButtonTitle.uppercased(), for: .normal)
    }

    func showBlurScene() {

        blurSlider.alpha = 0
        applyBlurButton.alpha = 0

        backScrollView.isHidden = false
        blurControlsView.isHidden = false
        bottomRightButton.isHidden = false

        setScrollInsets()
        setZoomScale()
        bottomRightButton.setTitle(viewModel.nextButtonTitle.uppercased(), for: .normal)

        showUndoButton(true)
    }

    func showProfileScene() {
        backScrollView.isHidden = false
        overlayView.isHidden = false
        photoLabel.isHidden = false
        bottomRightButton.isHidden = false

        setZoomScale()
        setScrollInsets()
        setOverlay()

        photoLabel.text = viewModel.profilePictureLabel
        bottomRightButton.setTitle(viewModel.nextButtonTitle.uppercased(), for: .normal)
        showUndoButton(false)
    }

    func showSearchScene() {
        backScrollView.isHidden = false
        overlayView.isHidden = false
        photoLabel.isHidden = false
        bottomRightButton.isHidden = false

        setZoomScale()
        setScrollInsets()
        setOverlay()

        photoLabel.text = viewModel.searchPictureLabel
        bottomRightButton.setTitle(viewModel.nextButtonTitle.uppercased(), for: .normal)
    }

    func showNextButton(_ show: Bool){
        if show {
            navigationItem.setRightBarButton(nextButton, animated: true)
        } else {
            navigationItem.setRightBarButton(nil, animated: true)
        }
    }
    func showBackButton(_ show: Bool){
        if show {
            navigationItem.setLeftBarButton(backButton, animated: true)
        } else {
            navigationItem.setLeftBarButton(nil, animated: true)
        }
    }

    func showUndoButton(_ show: Bool){
        if show {
            navigationItem.setRightBarButton(undoButton, animated: true)
        } else {
            navigationItem.setRightBarButton(nil, animated: true)
        }
    }

    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        switch scrollView {
        default:
            return mainImageView
        }
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        blur?.draw()
        setScrollInsets()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        blur?.draw()
    }

    func setZoomScale() {
        if scene == .profilePic {
            self.backScrollView.setZoomScale(aRect: mainImageView.imageBounds(), fitIn: profileOverlay.bounds, animated: false)
        } else if scene == .searchPic {
            self.backScrollView.setZoomScale(aRect: mainImageView.imageBounds(), fitIn: searchOverlay.bounds, animated: false)
        } else {
            self.backScrollView.setZoomScale(aRect: mainImageView.imageBounds(), fitIn: imageContainerView.bounds, animated: false)
        }
    }

    func setScrollInsets() {
        // image offset
        let imageFrame = mainImageView.imageFrame()
        let imageXOffset = imageFrame.minX
        let imageYOffset = imageFrame.minY
        //log.debug("image frame: \(imageFrame)")


        // Overlay inset
        var overlayHInset: CGFloat = 0
        var overlayVInset: CGFloat = 0
        if scene == .profilePic {
            overlayHInset = min(max(
                imageFrame.width - profileOverlay.frame.minX - profileOverlay.frame.width,
                0
            ), profileOverlay.frame.minX)
            overlayVInset = min(max(
                imageFrame.height - profileOverlay.frame.minY - profileOverlay.frame.height,
                0
            ), profileOverlay.frame.minY)
        } else if scene == .searchPic {
            overlayHInset = min(max(
                imageFrame.width - searchOverlay.frame.minX - searchOverlay.frame.width,
                0
            ), searchOverlay.frame.minX)
            overlayVInset = min(max(
                imageFrame.height - searchOverlay.frame.minY - searchOverlay.frame.height,
                0
            ), searchOverlay.frame.minY)
        }

        //log.debug("overlayHInset: \(overlayHInset)")
        //log.debug("overlayVInset: \(overlayVInset)")

        let zoomScale = 1 / backScrollView.zoomScale - 1

        let hInset = max(mainImageView.frame.width * zoomScale + imageXOffset, -imageXOffset) + overlayHInset
        //log.debug("hInset: \(hInset)")
        backScrollView.contentInset.left = hInset
        backScrollView.contentInset.right = hInset

        let vInset = max(mainImageView.frame.height * zoomScale + imageYOffset, -imageYOffset) + overlayVInset
        //log.debug("vInset: \(vInset)")
        backScrollView.contentInset.top = vInset
        backScrollView.contentInset.bottom = vInset
    }

    // MARK: - GZEDismissVCDelegate
    func onDismissTapped(_ vc: UIViewController) {
        if vc.isKind(of: GZEPaymentMethodsViewController.self) {
            let loginDismiss = viewModel.dismiss
            viewModel.dismiss = {[weak self] in
                guard let this = self else {return}
                this.performSegue(withIdentifier: this.segueToPayment, sender: nil)
                this.viewModel.dismiss = loginDismiss
            }
            vc.previousController(animated: true)
        } else if vc.isKind(of: GZERegisterPayPalViewController.self) {
            let loginDismiss = viewModel.dismiss
            viewModel.dismiss = {[weak self] in
                guard let this = self else {return}
                this.performSegue(withIdentifier: this.segueToRegisterPayPal, sender: nil)
                this.viewModel.dismiss = loginDismiss
            }
            vc.previousController(animated: true)
        }
    }

    func onNextTapped(_ vc: UIViewController) {
        if vc.isKind(of: GZERegisterPayPalViewController.self) {
            self.showChooseModeController()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == segueToPayment {
            showPaymentView(segue.destination)
        } else if segue.identifier == segueToRegisterPayPal {

            let nextButton = GZENextUIBarButtonItem()
            nextButton.onButtonTapped = {[weak self] _ in
                self?.showChooseModeController()
            }

            GZERegisterPayPalViewController.prepareView(presenter: self, nextDelegate: self, viewController: segue.destination, vm: GZERegisterPayPalViewModel(), rightBarButton: nextButton)
        }
    }


    func showPaymentView(_ vc: UIViewController) {
        log.debug("Trying to show payment view...")
        if let view = vc as? GZEPaymentMethodsViewController {

            view.dismissDelegate = self

            let vm = self.viewModel.paymentViewModel
            let nextButton = GZENextUIBarButtonItem()
            nextButton.onButtonTapped = {[weak self] _ in
                self?.showChooseModeController()
            }
            vm.navigationRightButton.value = nextButton

            view.viewModel = vm
        } else {
            log.error("Unable to instantiate GZEPaymentViewController")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
        }
    }

    func showChooseModeController() {
        self.viewModel.dismiss?()
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
