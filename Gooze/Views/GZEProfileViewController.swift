//
//  GZEProfileViewController.swift
//  Gooze
//
//  Created by Yussel on 2/22/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZEProfileViewController: UIViewController {

    var viewModel: GZEProfileViewModel!

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var phraseLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var languagesLabel: UILabel!
    @IBOutlet weak var ocupationLabel: UILabel!
    @IBOutlet weak var interestsLabel: UILabel!

    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var contactButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setLabelFormat(usernameLabel)
        setLabelFormat(phraseLabel)
        setLabelFormat(genderLabel)
        setLabelFormat(ageLabel)
        setLabelFormat(heightLabel)
        setLabelFormat(weightLabel)
        setLabelFormat(originLabel)
        setLabelFormat(languagesLabel)
        setLabelFormat(ocupationLabel)
        setLabelFormat(interestsLabel)

        contactButton.layer.borderWidth = 1
        contactButton.layer.borderColor = GZEConstants.Color.mainGreen.cgColor
        contactButton.layer.cornerRadius = 5
        contactButton.layer.masksToBounds = true

//        if let myString = contactButton.currentTitle as NSString? {
//            let stringSize = myString.size(attributes: [NSFontAttributeName: contactButton.titleLabel!.font!])
//            contactButton.frame.size.width = stringSize.width
//            log.debug("contact button width changed to: \(stringSize.width)")
//        }

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

    private func setLabelFormat(_ label: UILabel) {
        label.font = GZEConstants.Font.main
        label.textColor = UIColor.white
        label.textAlignment = .center
    }

    private func setUpBindings() {
        usernameLabel.reactive.text <~ viewModel.username
        phraseLabel.reactive.text <~ viewModel.phrase
        genderLabel.reactive.text <~ viewModel.gender
        ageLabel.reactive.text <~ viewModel.age
        heightLabel.reactive.text <~ viewModel.height
        weightLabel.reactive.text <~ viewModel.weight
        originLabel.reactive.text <~ viewModel.origin
        languagesLabel.reactive.text <~ viewModel.languages
        ocupationLabel.reactive.text <~ viewModel.ocupation
        interestsLabel.reactive.text <~ viewModel.interestedIn

        if let urlReq = viewModel.profilePic.value {
            profileImageView.af_setImage(withURLRequest: urlReq)
        }
    }
}
