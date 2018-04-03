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

    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var contactButton: GZEButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        setupInterfaceObjects()
        setUpBindings()
        setMode(mode: viewModel.mode.value)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.observeMessages()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewModel.stopObservingMessages()
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

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }

    private func setupInterfaceObjects() {
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

        viewModel.mode.signal.observeValues {[weak self] mode in
            guard let this = self else {return}
            this.setMode(mode: mode)
        }

        viewModel.error.signal.observeValues { error in
            error.flatMap {
                GZEAlertService.shared.showBottomAlert(superview: self.view, text: $0)
            }
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

        profileImageView.reactive.imageUrlRequest <~ viewModel.profilePic
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
        // Open chat
        log.debug("Trying to show chat controller...")
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let chatController = mainStoryboard.instantiateViewController(withIdentifier: "GZEChatViewController") as? GZEChatViewController {
            
            log.debug("chat controller instantiated. Setting up its view model")
            // Set up initial view model
            chatController.viewModel = self.viewModel.chatViewModel
            chatController.onDismissTapped = {[weak self] in
                self?.dismiss(animated: true)
            }
            self.present(chatController, animated: true)
        } else {
            log.error("Unable to instantiate GZEChatViewController")
            GZEAlertService.shared.showBottomAlert(superview: self.view, text: GZERepositoryError.UnexpectedError.localizedDescription)
        }
        viewModel.acceptRequest()
    }
}
