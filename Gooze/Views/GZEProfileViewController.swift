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

    let segueToUpdateProfile = "segueToUpdateProfile"

    var viewModel: GZEProfileUserInfoViewModel!

    @IBOutlet weak var scrollContentView: UIView!
    @IBOutlet weak var usernameLabel: GZELabel!
    @IBOutlet weak var phraseLabel: GZELabel!
    @IBOutlet weak var genderLabel: GZELabel!
    @IBOutlet weak var ageLabel: GZELabel!
    @IBOutlet weak var heightLabel: GZELabel!
    @IBOutlet weak var weightLabel: GZELabel!
    @IBOutlet weak var originLabel: GZELabel!
    @IBOutlet weak var languagesLabel: GZELabel!
    @IBOutlet weak var interestsLabel: GZELabel!

    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var ageButton: UIButton!
    @IBOutlet weak var heightButton: UIButton!
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var originButton: UIButton!
    @IBOutlet weak var languagesButton: UIButton!
    @IBOutlet weak var interestsButton: UIButton!

    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var contactButton: GZEButton!

    @IBOutlet weak var editButton: GZEEditButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("\(self) init")

        setupInterfaceObjects()
        setUpBindings()
        viewModel.didLoadObs.send(value: ())
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
        if segue.identifier == segueToUpdateProfile {
            prepareUpdateProfileSegue(segue.destination, vm: sender)
        }
    }

    func prepareUpdateProfileSegue(_ vc: UIViewController, vm: Any?) {
        guard let profileVc = vc as? GZESignUpProfileViewController else {
            log.error("unexpected segue destination \(vc) expecting GZESignUpProfileViewController")
            return
        }

        guard let profileVm = vm as? GZEUpdateProfileViewModel else {
            log.error("unexpected segue sender \(String(describing: vm)), expecting GZEUpdateProfileViewModel")
            return
        }
        

        profileVm.dismiss = {

        }
        profileVc.viewModel = profileVm
        profileVc.scene = .editProfile
    }

    private func setupInterfaceObjects() {
        navigationItem.hidesBackButton = true

        usernameLabel.setWhiteFontFormat()
        phraseLabel.setWhiteFontFormat()
        genderLabel.setWhiteFontFormat()
        ageLabel.setWhiteFontFormat()
        heightLabel.setWhiteFontFormat()
        weightLabel.setWhiteFontFormat()
        originLabel.setWhiteFontFormat()
        languagesLabel.setWhiteFontFormat()
        //ocupationLabel.setWhiteFontFormat()
        interestsLabel.setWhiteFontFormat()

        contactButton.enableAnimationOnPressed()
        contactButton.setGrayFormat()

    }

    private func setUpBindings() {

        viewModel.error.signal.observeValues { error in
            error.flatMap {
                GZEAlertService.shared.showBottomAlert(text: $0)
            }
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

        viewModel.dismissSignal
            .observeValues {[weak self] in
                guard let this = self else {return}
                this.previousController(animated: true)
        }

        viewModel.segueToUpdateProfile
            .observeValues {[weak self] vm in
                guard let this = self else {return}
                this.performSegue(withIdentifier: this.segueToUpdateProfile, sender: vm)
        }

        usernameLabel.reactive.text <~ viewModel.username
        phraseLabel.reactive.text <~ viewModel.phrase
        genderLabel.reactive.text <~ viewModel.gender
        ageLabel.reactive.text <~ viewModel.age
        heightLabel.reactive.text <~ viewModel.height
        weightLabel.reactive.text <~ viewModel.weight
        originLabel.reactive.text <~ viewModel.origin
        languagesLabel.reactive.text <~ viewModel.languages
        //ocupationLabel.reactive.text <~ viewModel.ocupation
        interestsLabel.reactive.text <~ viewModel.interestedIn

        profileImageView.reactive.noirImageUrlRequestLoading <~ viewModel.profilePic

        contactButton.reactive.isHidden <~ viewModel.actionButtonIsHidden
        contactButton.reactive.title <~ viewModel.actionButtonTitle
        contactButton.reactive.pressed = viewModel.bottomButtonAction

        genderButton.reactive.pressed = viewModel.genderAction.value
        ageButton.reactive.pressed = viewModel.ageAction.value
        heightButton.reactive.pressed = viewModel.heightAction.value
        weightButton.reactive.pressed = viewModel.weightAction.value
        originButton.reactive.pressed = viewModel.originAction.value
        languagesButton.reactive.pressed = viewModel.languagesAction.value
        interestsButton.reactive.pressed = viewModel.interestedInAction.value

        editButton.reactive.pressed = viewModel.editUserAction.value
    }
    
    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
