//
//  GZEGalleryViewController.swift
//  Gooze
//
//  Created by Yussel on 3/6/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZEGalleryViewController: UIViewController {

    var viewModel: GZEGalleryViewModel!

    var contactButtonTitle = "vm.profile.contactTitle".localized().uppercased()

    @IBOutlet weak var usernameLabel: GZELabel!

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var thumbnail1: UIImageView!
    @IBOutlet weak var thumbnail2: UIImageView!
    @IBOutlet weak var thumbnail3: UIImageView!
    @IBOutlet weak var thumbnail4: UIImageView!

    @IBOutlet weak var contactButton: GZEButton!

    var thumbnailImages = [UIImageView]()

    let selectedThumbnail = MutableProperty<UIImage?>(nil)


    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("\(self) init")

        // Do any additional setup after loading the view.
        thumbnailImages.append(thumbnail1)
        thumbnailImages.append(thumbnail2)
        thumbnailImages.append(thumbnail3)
        thumbnailImages.append(thumbnail4)

        setupInterfaceObjects()

        setupBindings()

        setMode(mode: viewModel.mode.value)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UIAction
    func thumbnailTappedHandler(_ gesture: UITapGestureRecognizer) {
        if let view = gesture.view {
            selectThumbnail(pos: view.tag)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    private func setupInterfaceObjects() {
        for (i, thumbnailImage) in thumbnailImages.enumerated() {
            thumbnailImage.tag = i
            thumbnailImage.addGestureRecognizer(
                UITapGestureRecognizer(
                    target: self,
                    action: #selector(thumbnailTappedHandler(_:))
                )
            )
        }

        contactButton.enableAnimationOnPressed()
        contactButton.setGrayFormat()
        view.layoutIfNeeded()
    }

    private func setupBindings() {
        viewModel.mode.signal.observeValues {[weak self] mode in
            guard let this = self else {return}
            this.setMode(mode: mode)
        }
        
        viewModel.error.signal.observeValues { error in
            error.flatMap {
                GZEAlertService.shared.showBottomAlert(superview: self.view, text: $0)
            }
        }
        
        // Model bindings
        usernameLabel.reactive.text <~ viewModel.username

        for (i, thumbnailImage) in thumbnailImages.enumerated() {
            if i >= viewModel.thumbnails.count  {
                break;
            }
            thumbnailImage.reactive.imageUrlRequest <~ viewModel.thumbnails[i]
        }

        // UI bindings
        mainImageView.reactive.image <~ selectedThumbnail
    }

    func selectThumbnail(pos: Int) {
        if pos < thumbnailImages.count {
            selectedThumbnail.value = thumbnailImages[pos].image
        }
    }

    func setMode(mode: GZEProfileMode) {
        var btnTitle: String
        var selector: Selector
        if mode == .request {
            btnTitle = self.viewModel.acceptRequestButtonTitle
            selector = #selector(self.acceptRequest)
        } else {
            btnTitle = self.viewModel.contactButtonTitle
            selector = #selector(self.contact)
        }
        self.contactButton.setTitle(btnTitle, for: .normal)
        self.contactButton.removeAllTargets()
        self.contactButton.addTarget(self, action: selector, for: .touchUpInside)
    }

    func contact() {
        viewModel.contact()
    }

    func acceptRequest() {
        viewModel.acceptRequest()
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
