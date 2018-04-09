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

    var viewModel: GZERatingsViewModel!

    var contactButtonTitle = "vm.profile.contactTitle".localized().uppercased()

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("\(self) init")
        
        viewModel.controller = self

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    private func setupInterfaceObjects() {
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
        
        imagesRatingView.showInfoLabel = false
        complianceRatingView.showInfoLabel = false
        dateQualityRatingView.showInfoLabel = false
        dateRatingView.showInfoLabel = false
        goozeRatingView.showInfoLabel = false
    }

    private func setUpBindings() {
        viewModel.error.signal.observeValues { error in
            error.flatMap {
                GZEAlertService.shared.showBottomAlert(text: $0)
            }
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

        overallRatingView.reactive.rating <~ viewModel.overallRating
        
        contactButton.reactive.title <~ viewModel.actionButtonTitle
        contactButton.reactive.pressed = CocoaAction(self.viewModel.acceptRequestAction) { [weak self] _ in
            self?.showLoading()
        }
        
        viewModel.acceptRequestAction.events.observeValues {[weak self] _ in
            self?.hideLoading()
        }
    }
    
    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
