//
//  GZERatingsViewController.swift
//  Gooze
//
//  Created by Yussel on 3/6/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZERatingsViewController: UIViewController {

    var segueToProfile = "segueToProfile"
    var unwindToActivateGooze = "unwindToActivateGooze"

    var viewModel: GZERatingsViewModel!

    @IBOutlet weak var usernameLabel: GZELabel!
    @IBOutlet weak var phraseLabel: GZELabel!
    @IBOutlet weak var imagesRatingLabel: GZELabel!
    @IBOutlet weak var complianceRatingLabel: GZELabel!
    @IBOutlet weak var dateQualityRatingLabel: GZELabel!
    @IBOutlet weak var dateRatingLabel: GZELabel!
    @IBOutlet weak var goozeRatingLabel: GZELabel!

    @IBOutlet weak var imagesRatingView: GZERatingView!
    @IBOutlet weak var complianceRatingView: GZERatingView!
    @IBOutlet weak var dateQualityRatingView: GZERatingView!
    @IBOutlet weak var dateRatingView: GZERatingView!
    @IBOutlet weak var goozeRatingView: GZERatingView!
    @IBOutlet weak var overallRatingView: GZERatingView!

    
    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var contactButton: GZEButton!
    @IBOutlet weak var phraseButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("\(self) init")

        setupInterfaceObjects()
        setUpBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.startObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewModel.stopObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == segueToProfile {

            showProfileView(segue.destination)

        }
    }


    private func setupInterfaceObjects() {
        navigationItem.hidesBackButton = true

        contactButton.enableAnimationOnPressed()
        contactButton.setGrayFormat()
        
        usernameLabel.setWhiteFontFormat()
        phraseLabel.setWhiteFontFormat()
        imagesRatingLabel.setWhiteFontFormat(align: .left)
        complianceRatingLabel.setWhiteFontFormat(align: .left)
        dateQualityRatingLabel.setWhiteFontFormat(align: .left)
        dateRatingLabel.setWhiteFontFormat(align: .left)
        goozeRatingLabel.setWhiteFontFormat(align: .left)
        
        overallRatingView.infoLabel.font = GZEConstants.Font.mainBig
        overallRatingView.setEditable(false)
        
        imagesRatingView.showInfoLabel = false
        complianceRatingView.showInfoLabel = false
        dateQualityRatingView.showInfoLabel = false
        dateRatingView.showInfoLabel = false
        goozeRatingView.showInfoLabel = false
    }

    private func setUpBindings() {
        viewModel.error.signal.skipNil().observeValues { error in
            GZEAlertService.shared.showBottomAlert(text: error)
        }

        viewModel.loading
            .producer
            .startWithValues {[weak self] loading in
                guard let this = self else {return}
                if loading {
                    this.showLoading()
                } else {
                    this.hideLoading()
                }
            }

        viewModel.disposeToActivateGooze
            .observeValues {[weak self] in
                guard let this = self else {return}
                this.performSegue(withIdentifier: this.unwindToActivateGooze, sender: nil)
            }

        viewModel.segueToProfile
            .observeValues {[weak self] in
                guard let this = self else {return}
                this.performSegue(withIdentifier: this.segueToProfile, sender: nil)
        }
        
        usernameLabel.reactive.text <~ viewModel.username
        profileImageView.reactive.imageUrlRequest <~ viewModel.profilePic
        phraseLabel.reactive.text <~ viewModel.phrase

        imagesRatingLabel.reactive.text <~ viewModel.imagesRatingDesc
        complianceRatingLabel.reactive.text <~ viewModel.complianceRatingDesc
        dateQualityRatingLabel.reactive.text <~ viewModel.dateQualityRatingDesc
        dateRatingLabel.reactive.text <~ viewModel.dateRatingDesc
        goozeRatingLabel.reactive.text <~ viewModel.goozeRatingDesc

        imagesRatingView.reactive.rating <~ viewModel.imagesRating
        complianceRatingView.reactive.rating <~ viewModel.complianceRating
        dateQualityRatingView.reactive.rating <~ viewModel.dateQualityRating
        dateRatingView.reactive.rating <~ viewModel.dateRating
        goozeRatingView.reactive.rating <~ viewModel.goozeRating

        imagesRatingView.reactive.isEditable <~ viewModel.imagesRatingIsEditable
        complianceRatingView.reactive.isEditable <~ viewModel.complianceRatingIsEditable
        dateQualityRatingView.reactive.isEditable <~ viewModel.dateQualityRatingIsEditable
        dateRatingView.reactive.isEditable <~ viewModel.dateRatingIsEditable
        goozeRatingView.reactive.isEditable <~ viewModel.goozeRatingIsEditable

        overallRatingView.reactive.rating <~ viewModel.overallRating

        // Input producers
        viewModel.imagesRating <~ imagesRatingView.ratingProducer.on{log.debug($0)}
        viewModel.complianceRating <~ complianceRatingView.ratingProducer.on{log.debug($0)}
        viewModel.dateQualityRating <~ dateQualityRatingView.ratingProducer.on{log.debug($0)}
        viewModel.dateRating <~ dateRatingView.ratingProducer.on{log.debug($0)}
        viewModel.goozeRating <~ goozeRatingView.ratingProducer.on{log.debug($0)}

        // Actions

        contactButton.reactive.title <~ viewModel.actionButtonTitle
        contactButton.reactive.pressed = viewModel.bottomButtonAction

        phraseButton.reactive.pressed = viewModel.phraseButtonAction
    }

    func showProfileView(_ vc: UIViewController) {
        log.debug("Trying to show profile view...")
        if let view = vc as? GZEProfileViewController {

            view.viewModel = self.viewModel.profileViewModel
        } else {
            log.error("Unable to instantiate GZEProfileViewController")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
        }
    }
    
    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
