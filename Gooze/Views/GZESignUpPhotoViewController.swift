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
import iCarousel

class GZESignUpPhotoViewController: UIViewController, UIScrollViewDelegate {

    var blur: GZEBlur?
    // TODO: Remove asign
    var viewModel: GZESignUpViewModel! = GZESignUpViewModel(GZEUserApiRepository())

    var saveProfileAction: CocoaAction<UIButton>!
    var saveSearchAction: CocoaAction<UIButton>!
    var saveGalleryAction: CocoaAction<UIButton>!

    var selectedImageButton: UIButton?

    var currentPhotoNum = 0

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
        case reel
        case camera

        case gallery
    }

    var cropArea: CGRect {
        var overlay: UIView

        if scene == .profilePic {
            overlay = profileOverlay
        } else {
            overlay = searchOverlay
        }

        let factor: CGFloat = 1 //photoImageView.image!.size.width/imageContainerView.frame.width
        let scale: CGFloat = 1/backScrollView.zoomScale
        let imageFrame = photoImageView.imageFrame()
        let x = (backScrollView.contentOffset.x + overlay.frame.origin.x - imageFrame.origin.x) * scale * factor
        let y = (backScrollView.contentOffset.y + overlay.frame.origin.y - imageFrame.origin.y) * scale * factor
        let width = overlay.frame.size.width * scale * factor
        let height = overlay.frame.size.height * scale * factor

        let resultArea = CGRect(x: x, y: y, width: width, height: height)

        log.debug("factor: \(factor)")
        log.debug("scale: \(scale)")
        log.debug("backScrollView.contentOffset: \(backScrollView.contentOffset)")
        log.debug("profileOverlay.frame: \(profileOverlay.frame)")
        log.debug("imageFrame: \(imageFrame)")
        log.debug("resultArea: \(resultArea)")

        return resultArea
    }

    @IBOutlet weak var backScrollView: UIScrollView! {
        didSet {
            backScrollView.delegate = self
        }
    }

    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var searchOverlay: UIView!
    @IBOutlet weak var profileOverlay: UIView!
    @IBOutlet weak var cameraOrReelView: UIView!
    @IBOutlet weak var blurEffectView: UIView!
    @IBOutlet weak var editButtonView: UIView!
    @IBOutlet weak var photoThumbnailsView: UIView!
    @IBOutlet weak var blurControlsView: UIView!

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoImageView2: UIImageView!
    @IBOutlet weak var photoImageView3: UIImageView!
    @IBOutlet weak var photoImageView4: UIImageView!
    @IBOutlet weak var photoImageView5: UIImageView!

    @IBOutlet weak var saveButton: UIBarButtonItem!

    @IBOutlet weak var bottomRightButton: UIButton!
    @IBOutlet weak var bottomBackButton: UIButton!
    @IBOutlet weak var editButton2: UIButton!
    @IBOutlet weak var editButton3: UIButton!
    @IBOutlet weak var editButton4: UIButton!
    @IBOutlet weak var editButton5: UIButton!
    @IBOutlet weak var blurButton: UIButton!

    @IBOutlet weak var photoLabel: UILabel!

    @IBOutlet weak var blurSlider: UISlider!

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

    func logScrollBounds() {
        log.debug("back scroll: \(backScrollView.bounds)")

        log.debug("photoImageView: \(photoImageView.bounds)")
        log.debug("photoImage: \(photoImageView.imageFrame())")
    }

    func logScrollOffset() {
        log.debug("back contentOffset: \(backScrollView.contentOffset)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        // TODO: SetLayout here or in viewDidAppear to work in landscape mode?????
        setLayout()
        initBlur()

        photoImageViews.append(photoImageView)
        photoImageViews.append(photoImageView2)
        photoImageViews.append(photoImageView3)
        photoImageViews.append(photoImageView4)
        photoImageViews.append(photoImageView5)

        editButtonView.layer.cornerRadius = 5

        photoImageView.reactive.image <~ viewModel.mainImage

        saveButton.reactive.pressed = CocoaAction(viewModel.savePhotosAction)

        saveProfileAction = CocoaAction(viewModel.saveProfilePicAction)
        { [weak self] _ in
            self?.showLoading()
        }
        saveSearchAction = CocoaAction(viewModel.saveSearchPicAction)
        { [weak self] _ in
            self?.showLoading()
        }
        saveGalleryAction = CocoaAction(viewModel.savePhotosAction)
        { [weak self] _ in
            self?.showLoading()
        }

//        viewModel.saveProfilePicAction.values.observeValues(onSaveProfileSuccess(user:))
//        viewModel.saveSearchPicAction.values.observeValues(onSaveSearchSuccess(user:))
//        viewModel.savePhotosAction.values.observeValues(onSaveGallerySuccess(user:))

        viewModel.saveProfilePicAction.events.observeValues(onEvent(event:))
        viewModel.saveSearchPicAction.events.observeValues(onEvent(event:))
        viewModel.savePhotosAction.events.observeValues(onEvent(event:))

        switch mode {
        case .editGalleryPic:
            scene = .gallery
        case .editProfilePic:
            scene = .cameraOrReel
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // setLayout()
        setOverlay()

        backScrollView.setZoomScale(imageView: photoImageView, animated: false)
        backScrollView.centerContent(animated: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewDidLayoutSubviews() {
        log.debug("Search bounds: \(searchOverlay.bounds)")
        super.viewDidLayoutSubviews()

        setOverlayConstraints()

        blur?.draw()

        log.debug("Image container bounds: \(imageContainerView.bounds)")
        log.debug("Search bounds: \(searchOverlay.bounds)")
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        log.debug("View Will Transition to size: \(size)")

        setLayout(size)

        log.debug("Search bounds: \(searchOverlay.bounds)")

        coordinator.animate(alongsideTransition: nil, completion: {
            [weak self]_ in

            guard let this = self else {
                return
            }
            log.debug("Search bounds: \(this.searchOverlay.bounds)")
            this.setOverlay()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Actions
    @IBAction func nextButtonTapped(_ sender: Any) {
        switch scene! {
        case .profilePic:
            let croppedImage = photoImageView.crop(to: cropArea)
            viewModel.profilePic.value = croppedImage
            saveProfileAction.execute(sender)
        case .searchPic:
            let croppedImage = photoImageView.crop(to: cropArea)
            viewModel.searchPic.value = croppedImage
            saveSearchAction.execute(sender)
            break
        case .blur:
            viewModel.mainImage.value = blur?.resultImage
            blur = nil
            switch mode {
            case .editProfilePic:
                scene = .profilePic
            case .editGalleryPic:
                // TODO: save and go to gallery
                scene = .gallery
            }
        default:
            break
        }
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        switch scene! {
        case .profilePic:
            scene = .cameraOrReel
        case .searchPic:
            scene = .profilePic
        case .blur:
            if let blur = blur, blur.isDirty {
                blur.revert()
            } else {
                scene = .cameraOrReel
            }
        default:
            break
        }
    }

    @IBAction func editPhotoButtonTapped(_ sender: UIButton) {
        editPhoto()
    }

    @IBAction func addPhoto(_ sender: UIButton) {
        //carousel.appendPhoto(nil)


        viewModel.photos.append(MutableProperty(GZEUser.Photo(image: nil)))
        currentPhotoNum = viewModel.photos.count - 1
        editPhoto()
    }

    @IBAction func blurButtonTapped(_ sender: Any) {
        blur?.apply()
    }

    func blurPinched(_ gestureRecognizer: UIPinchGestureRecognizer) {

        let scale = gestureRecognizer.scale

        guard let view = gestureRecognizer.view else {
            log.debug("Gesture doesn't have a view")
            return
        }

        log.debug(view.transform)
        log.debug(scale)

        let transform = view.transform.scaledBy(x: scale, y: scale)

        guard transform.a >= 1 else {
            log.debug("Reached min size")
            return
        }

        view.transform = transform
        gestureRecognizer.scale = 1

        blur?.draw()
    }

    func blurPan(_ gestureRecognizer: UIPanGestureRecognizer) {

        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.view)

            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        }

        blur?.draw()
    }

    func initBlur() {
        blurButton.setTitle(viewModel.blurButtonTitle, for: .normal)
        blurSlider.reactive.values.debounce(0.3, on: QueueScheduler.main).observeValues { [weak self] in
            self?.blur?.radius = $0
        }

        blurEffectView.layer.borderWidth = 1
        blurEffectView.layer.borderColor = UIColor.white.cgColor
        blurEffectView.layer.cornerRadius = blurEffectView.frame.size.width / 2

        blurEffectView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(blurPan(_:))))
        blurEffectView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(blurPinched(_:))))
    }

    func editPhoto() {
        let cameraViewController = CameraViewController(croppingParameters: CroppingParameters(isEnabled: false)) { [weak self] image, asset in

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

                guard this.currentPhotoNum >= 0 else {
                    log.warning("Invalid photo number")
                    return
                }

            this.viewModel.mainImage.value = compressedImage

            this.blur = GZEBlur(image: compressedImage, blurEffectView: this.blurEffectView, resultImageView: this.photoImageView, scrollView: this.backScrollView)

            this.scene = .blur
            this.dismiss(animated: true, completion: nil)
        }

        present(cameraViewController, animated: true, completion: nil)
    }

    func setLayout(_ size: CGSize? = nil) {
        var viewSize: CGSize
        if size == nil {
            viewSize = view.bounds.size
        } else {
            viewSize = size!
        }

        log.debug("viewSize: \(viewSize)")
        log.debug("Image container bounds: \(imageContainerView.bounds)")

        if viewSize.width > viewSize.height {
            setLandscapeLayout()
        } else {
            setPortraitLayout()
        }


        log.debug("Image container bounds: \(imageContainerView.bounds)")
        log.debug("Search bounds: \(searchOverlay.bounds)")
    }

    func setPortraitLayout() {
        log.debug("Portrait layout set")
        imageContainerTrailingViewLeadingConstraint.isActive = false
        superViewBottomImageContainerBottomConstraint.isActive = false
        superviewTopViewTopConstraint.isActive = false
        bottomViewWidthConstraint.isActive = false

        superviewTrailingImageContainerTrailingConstraint.isActive = true
        viewTopImageContainerBottomConstraint.isActive = true
        viewLeadingSuperviewLeadingConstrint.isActive = true
        bottomViewHeightConstraint.isActive = true
    }

    func setLandscapeLayout() {
        log.debug("Landscape layout set")
        superviewTrailingImageContainerTrailingConstraint.isActive = false
        viewTopImageContainerBottomConstraint.isActive = false
        viewLeadingSuperviewLeadingConstrint.isActive = false
        bottomViewHeightConstraint.isActive = false

        imageContainerTrailingViewLeadingConstraint.isActive = true
        superViewBottomImageContainerBottomConstraint.isActive = true
        superviewTopViewTopConstraint.isActive = true
        bottomViewWidthConstraint.isActive = true
    }

    func setOverlayConstraints() {
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

        log.debug("Image container bounds: \(imageContainerView.bounds)")
        log.debug("Search bounds: \(searchOverlay.bounds)")
        log.debug("Search bounds: \(searchOverlay.frame)")

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
        maskLayer.fillRule = kCAFillRuleEvenOdd

        // Release the path since it's not covered by ARC.
        overlayView.layer.mask = maskLayer
    }

    // MARK: - Observer handlers
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
    }

    func onSaveSearchSuccess(user: GZEUser) {
        log.debug("Search pic saved")
        navigationController?.popViewController(animated: true)
    }

    func onSaveGallerySuccess(user: GZEUser) {
        log.debug("Gallery saved")
    }

    func onError(err: GZEError) {
        self.displayMessage(viewModel.viewTitle, err.localizedDescription)
    }

    // MARK: - Scenes
    func showCurrentScene() {

        hideAll()

        switch scene! {
        case .cameraOrReel:
            showCameraOrReelScene()
        case .blur:
            showBlurScene()
        case .profilePic:
            showProfileScene()
        case .searchPic:
            showSearchScene()
        case .gallery:
            showGallery()
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

        bottomRightButton.isHidden = true

        // TODO: remove buttons
        editButtonView.isHidden = true

    }

    func showGallery() {
        backScrollView.isHidden = false
        photoThumbnailsView.isHidden = false
    }

    func showCameraOrReelScene() {
        cameraOrReelView.isHidden = false
    }

    func showBlurScene() {
        backScrollView.isHidden = false
        blurControlsView.isHidden = false
        bottomRightButton.isHidden = false
        blurEffectView.isHidden = false

        bottomRightButton.setTitle(viewModel.nextButtonTitle, for: .normal)
    }

    func showProfileScene() {
        backScrollView.isHidden = false
        overlayView.isHidden = false
        photoLabel.isHidden = false
        bottomRightButton.isHidden = false

        setOverlay()
        backScrollView.setZoomScale(imageView: photoImageView, animated: false)
        backScrollView.centerContent(animated: false)

        photoLabel.text = viewModel.profilePictureLabel
        bottomRightButton.setTitle(viewModel.nextButtonTitle, for: .normal)
    }

    func showSearchScene() {
        backScrollView.isHidden = false
        overlayView.isHidden = false
        photoLabel.isHidden = false
        bottomRightButton.isHidden = false

        setOverlay()
        backScrollView.setZoomScale(imageView: photoImageView, animated: false)
        backScrollView.centerContent(animated: false)

        photoLabel.text = viewModel.searchPictureLabel
        bottomRightButton.setTitle(viewModel.nextButtonTitle, for: .normal)
    }

    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        switch scrollView {
        default:
            return scrollView.subviews.first
        }
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        blur?.draw()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        log.debug(backScrollView.contentOffset)
        blur?.draw()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
