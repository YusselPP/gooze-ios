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

        setupInterfaceObjects()
        setUpBindings()
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
        contactButton.setTitle(contactButtonTitle, for: .normal)
        contactButton.setGrayFormat()
    }

    private func setUpBindings() {
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
    }
}
