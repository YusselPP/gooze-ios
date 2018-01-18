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

class GZESignUpPhotoViewController: UIViewController {

    var viewModel: GZESignUpViewModel!

    var signUpErrorsObserver: Disposable?
    var signUpValuesObserver: Disposable?

    var selectedImageButton: UIButton?

    var currentPhotoNum = -1

    var photoImageViews: [UIImageView] = []

    @IBOutlet weak var saveButton: UIBarButtonItem!

    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var editButtonView: UIView!
    // @IBOutlet weak var carousel: GZECarouselUIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoImageView2: UIImageView!
    @IBOutlet weak var photoImageView3: UIImageView!
    @IBOutlet weak var photoImageView4: UIImageView!
    @IBOutlet weak var photoImageView5: UIImageView!

    @IBOutlet weak var editButton2: UIButton!
    @IBOutlet weak var editButton3: UIButton!
    @IBOutlet weak var editButton4: UIButton!
    @IBOutlet weak var editButton5: UIButton!


    @IBOutlet weak var superviewTrailingImageContainerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewTopImageContainerBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var viewLeadingSuperviewLeadingConstrint: NSLayoutConstraint!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var imageContainerTrailingViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var superViewBottomImageContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var superviewTopViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewWidthConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        //carousel.dataSource = viewModel.self
        //photoImageView.reactive.image <~ carousel.selectedImage
        //if carousel.currentItemIndex >= 0 {
        //    carousel.selectedImage.value = viewModel.photos[carousel.currentItemIndex].value?.image
        //}
        photoImageViews.append(photoImageView)
        photoImageViews.append(photoImageView2)
        photoImageViews.append(photoImageView3)
        photoImageViews.append(photoImageView4)
        photoImageViews.append(photoImageView5)

        editButtonView.layer.cornerRadius = 5

        imageContainerView.clipsToBounds = true

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
        setLayout()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        signUpValuesObserver?.dispose()
        signUpErrorsObserver?.dispose()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        log.debug("View Will Transition to size: \(size)")

        setLayout(size)
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

        if viewSize.width > viewSize.height {
            setLandscapeLayout()
        } else {
            setPortraitLayout()
        }
    }

    func setPortraitLayout() {
        imageContainerTrailingViewLeadingConstraint.isActive = false
        superViewBottomImageContainerBottomConstraint.isActive = false
        superviewTopViewTopConstraint.isActive = false
        viewWidthConstraint.isActive = false

        superviewTrailingImageContainerTrailingConstraint.isActive = true
        viewTopImageContainerBottomConstraint.isActive = true
        viewLeadingSuperviewLeadingConstrint.isActive = true
        viewHeightConstraint.isActive = true
    }

    func setLandscapeLayout() {
        superviewTrailingImageContainerTrailingConstraint.isActive = false
        viewTopImageContainerBottomConstraint.isActive = false
        viewLeadingSuperviewLeadingConstrint.isActive = false
        viewHeightConstraint.isActive = false

        imageContainerTrailingViewLeadingConstraint.isActive = true
        superViewBottomImageContainerBottomConstraint.isActive = true
        superviewTopViewTopConstraint.isActive = true
        viewWidthConstraint.isActive = true
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
