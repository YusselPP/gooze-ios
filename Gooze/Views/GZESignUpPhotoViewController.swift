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

    // TODO: Remove asign
    var viewModel: GZESignUpViewModel! = GZESignUpViewModel(GZEUserApiRepository())

    var signUpErrorsObserver: Disposable?
    var signUpValuesObserver: Disposable?

    var selectedImageButton: UIButton?

    var currentPhotoNum = -1

    var photoImageViews: [UIImageView] = []

    var scene: Scene = .searchPic

    enum Scene {
        case profilePic
        case searchPic

        case cameraOrReel
        case reel
        case camera

        case gallery
    }


    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var saveButton2: UIButton!

    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!

    @IBOutlet weak var backScrollView: UIScrollView! {
        didSet {
            backScrollView.delegate = self
        }
    }
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var searchOverlay: UIView!
    @IBOutlet weak var profileOverlay: UIView!


    @IBOutlet weak var editButtonView: UIView!
    // @IBOutlet weak var carousel: GZECarouselUIView!



    @IBOutlet weak var photoThumbnailsView: UIView!


    @IBOutlet weak var photoImageView2: UIImageView!
    @IBOutlet weak var photoImageView3: UIImageView!
    @IBOutlet weak var photoImageView4: UIImageView!
    @IBOutlet weak var photoImageView5: UIImageView!

    @IBOutlet weak var editButton2: UIButton!
    @IBOutlet weak var editButton3: UIButton!
    @IBOutlet weak var editButton4: UIButton!
    @IBOutlet weak var editButton5: UIButton!

    @IBOutlet weak var photoLabel: UILabel!

    @IBOutlet weak var blurControlsView: UIView!
    @IBOutlet weak var blurButton: UIButton!
    @IBOutlet weak var blurSlider: UISlider!

    // Landscape/Portrait layout constraints
    @IBOutlet weak var superviewTrailingImageContainerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewTopImageContainerBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var viewLeadingSuperviewLeadingConstrint: NSLayoutConstraint!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var imageContainerTrailingViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var superViewBottomImageContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var superviewTopViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomViewWidthConstraint: NSLayoutConstraint!


    @IBOutlet weak var searchOverlayLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchOverlayTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchOverlayTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchOverlayBottomConstraint: NSLayoutConstraint!


    @IBAction func blurButtonTapped(_ sender: Any) {
        logScrollBounds()
    }

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

        // TODO: SetLayout here or in viewDidApper to work in landscape mode?????
        setLayout()

        photoImageViews.append(photoImageView)
        photoImageViews.append(photoImageView2)
        photoImageViews.append(photoImageView3)
        photoImageViews.append(photoImageView4)
        photoImageViews.append(photoImageView5)

        editButtonView.layer.cornerRadius = 5

        blurButton.setTitle(viewModel.blurButtonTitle, for: .normal)

        saveButton.reactive.pressed = CocoaAction(viewModel.savePhotosAction)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.photos.enumerated().forEach { photoImageViews[$0.offset].image = $0.element.value?.image }

        signUpValuesObserver = viewModel.savePhotosAction.values.observeValues { [unowned self] res in
            self.displayMessage("Gooze", "User saved")
            log.debug(res)
        }

        signUpErrorsObserver = viewModel.savePhotosAction.errors.observeValues { [unowned self] (err: Error) in
            self.displayMessage("Error", err.localizedDescription)
        }
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setOverlay()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        signUpValuesObserver?.dispose()
        signUpErrorsObserver?.dispose()
    }

    override func viewDidLayoutSubviews() {
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

    // MARK: Actions

    @IBAction func editPhotoButtonTapped(_ sender: UIButton) {
        editPhoto()
    }

    @IBAction func addPhoto(_ sender: UIButton) {
        //carousel.appendPhoto(nil)

        viewModel.photos.append(MutableProperty(GZEUser.Photo(image: nil)))
        currentPhotoNum = viewModel.photos.count - 1
        editPhoto()
    }

    func editPhoto() {
        let cameraViewController = CameraViewController(croppingParameters: CroppingParameters(isEnabled: true)) { [weak self] image, asset in

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

            let blurViewController = GZEBlurViewController(image: compressedImage)

            blurViewController.onCompletion = { blurredImage in

                defer {
                    this.dismiss(animated: true, completion: nil)
                }

                guard let blurredImage = blurredImage else {
                    log.debug("Empty image received")
                    return
                }

                //guard let currentView = this.carousel.currentItemView as? UIImageView else {
                 //   log.warning("Carousel view not selected")
                //    return
                //}

                guard this.currentPhotoNum >= 0 else {
                    log.warning("Invalid photo number")
                    return
                }

                //this.carousel.selectedImage.value = blurredImage
                this.viewModel.photos[this.currentPhotoNum].value?.image = blurredImage
                this.photoImageViews[this.currentPhotoNum].image = blurredImage
                //currentView.image = blurredImage
            }

            this.dismiss(animated: true, completion: nil)
            this.present(blurViewController, animated: true, completion: nil)
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
        //viewWidthConstraint.isActive = false
        bottomViewWidthConstraint.isActive = false

        superviewTrailingImageContainerTrailingConstraint.isActive = true
        viewTopImageContainerBottomConstraint.isActive = true
        viewLeadingSuperviewLeadingConstrint.isActive = true
        //viewHeightConstraint.isActive = true
        bottomViewHeightConstraint.isActive = true
    }

    func setLandscapeLayout() {
        log.debug("Landscape layout set")
        superviewTrailingImageContainerTrailingConstraint.isActive = false
        viewTopImageContainerBottomConstraint.isActive = false
        viewLeadingSuperviewLeadingConstrint.isActive = false
        //viewHeightConstraint.isActive = false
        bottomViewHeightConstraint.isActive = false

        imageContainerTrailingViewLeadingConstraint.isActive = true
        superViewBottomImageContainerBottomConstraint.isActive = true
        superviewTopViewTopConstraint.isActive = true
        //viewWidthConstraint.isActive = true
        bottomViewWidthConstraint.isActive = true
    }

    func setOverlay() {

        log.debug("Image container bounds: \(imageContainerView.bounds)")
        log.debug("Search bounds: \(searchOverlay.bounds)")
        log.debug("Search bounds: \(searchOverlay.frame)")

        let path = CGMutablePath()

        if scene == .profilePic {

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

    // MARK: - Scenes

    func showProfileScene() {
        blurControlsView.isHidden = true
        photoThumbnailsView.isHidden = true

        photoLabel.text = viewModel.profilePictureLabel
        saveButton2.setTitle(viewModel.nextButtonTitle, for: .normal)
    }

    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        switch scrollView {
        default:
            return scrollView.subviews.first
        }
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {

    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        log.debug(backScrollView.contentOffset)
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
        log.debug("\(self) disposed")
    }
}
