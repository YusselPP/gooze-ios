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

        viewModel.controller = self
        // Do any additional setup after loading the view.
        thumbnailImages.append(thumbnail1)
        thumbnailImages.append(thumbnail2)
        thumbnailImages.append(thumbnail3)
        thumbnailImages.append(thumbnail4)

        setupInterfaceObjects()

        setupBindings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.startObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewModel.stopObservers()
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
        usernameLabel.setWhiteFontFormat()
        view.layoutIfNeeded()
    }

    private func setupBindings() {
        viewModel.error.signal.observeValues { error in
            error.flatMap {
                GZEAlertService.shared.showBottomAlert(text: $0)
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
        
        contactButton.reactive.title <~ viewModel.actionButtonTitle
        contactButton.reactive.pressed = CocoaAction(self.viewModel.acceptRequestAction) { [weak self] _ in
            self?.showLoading()
        }
        viewModel.acceptRequestAction.events.observeValues {[weak self] _ in
            self?.hideLoading()
        }

        // UI bindings
        mainImageView.reactive.image <~ selectedThumbnail
    }

    func selectThumbnail(pos: Int) {
        if pos < thumbnailImages.count {
            selectedThumbnail.value = thumbnailImages[pos].image
        }
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
