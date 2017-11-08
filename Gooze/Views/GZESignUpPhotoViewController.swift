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


    @IBOutlet weak var saveButton: UIBarButtonItem!

    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var editButtonView: UIView!
    @IBOutlet weak var carousel: GZECarouselUIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!


    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        carousel.dataSource = viewModel.self
        photoImageView.reactive.image <~ carousel.selectedImage
        if carousel.currentItemIndex >= 0 {
            carousel.selectedImage.value = viewModel.photos[carousel.currentItemIndex].value
        }

        editButtonView.layer.cornerRadius = 5

        imageContainerView.clipsToBounds = true

        blurEffectView.layer.cornerRadius = 20
        blurEffectView.layer.masksToBounds = true


        let panGesture = UIPanGestureRecognizer(target: self, action:(#selector(GZESignUpPhotoViewController.blurPan(_:))))
        blurEffectView.addGestureRecognizer(panGesture)

        saveButton.reactive.pressed = CocoaAction(viewModel.saveAction)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        signUpValuesObserver = viewModel.saveAction.values.observeValues { [unowned self] res in
            self.displayMessage("Gooze", "User saved")
            log.debug(res)
        }

        signUpErrorsObserver = viewModel.saveAction.errors.observeValues { [unowned self] (err: Error) in
            self.displayMessage("Error", err.localizedDescription)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setViewSize(blurEffectView, CGFloat(50), CGFloat(50))
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        signUpValuesObserver?.dispose()
        signUpErrorsObserver?.dispose()
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
        carousel.appendPhoto(nil)
        editPhoto()
    }

    @IBAction func blurPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)

        sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        
        sender.setTranslation(CGPoint.zero, in: self.view)
    }


    func setViewSize(_ view: UIView, _ width: CGFloat, _ heigth: CGFloat) -> Void {
        let frame = view.frame
        view.frame = CGRect(x: frame.minX, y: frame.minY, width: width, height: heigth)
    }

    func editPhoto() {
        let cameraViewController = CameraViewController(croppingParameters: CroppingParameters(isEnabled: true)) { [weak self] image, asset in

            log.debug("camera controller handler")

            guard let this = self else {
                log.error("self was dispossed before calling handler")
                return
            }

            if image != nil {

                let index = this.carousel.currentItemIndex

                if
                    let currView = this.carousel.currentItemView as? UIImageView,
                    index >= 0
                {
                    this.carousel.selectedImage.value = image
                    this.viewModel.photos[index].value = image
                    currView.image = image
                }
            } else {
                log.debug("Empty image received")
            }

            this.dismiss(animated: true, completion: nil)
        }

        present(cameraViewController, animated: true, completion: nil)
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
