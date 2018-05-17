//
//  GZEMapViewController.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/20/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZEMapViewController: UIViewController {

    var viewModel: GZEMapViewModel!
    var onDismissTapped: (() -> ())?

    var userBalloons = [GZEUserBalloon]()

    let backButton = GZEBackUIBarButtonItem()

    @IBOutlet weak var navItem: UINavigationItem!

    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var topSliderContainer: UIView!

    @IBOutlet weak var mapViewContainer: UIView!

    @IBOutlet weak var userBalloon1: GZEUserBalloon!{
        didSet{ self.userBalloons.append(self.userBalloon1) }
    }
    @IBOutlet weak var userBalloon2: GZEUserBalloon!{
        didSet{ self.userBalloons.append(self.userBalloon2) }
    }
    @IBOutlet weak var userBalloon3: GZEUserBalloon!{
        didSet{ self.userBalloons.append(self.userBalloon3) }
    }
    @IBOutlet weak var userBalloon4: GZEUserBalloon!{
        didSet{ self.userBalloons.append(self.userBalloon4) }
    }
    @IBOutlet weak var userBalloon5: GZEUserBalloon!{
        didSet{ self.userBalloons.append(self.userBalloon5) }
    }
    
    @IBOutlet weak var bottomActionView: GZEChatActionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("\(self) init")
        self.setupInterfaceObjects()
        self.setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.viewWillAppear(mapViewContainer: self.mapViewContainer                       )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewModel.viewDidDisappear()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupInterfaceObjects() {
        self.backButton.onButtonTapped = {[weak self] _ in
            self?.onDismissTapped?()
        }
        self.navItem.setLeftBarButton(self.backButton, animated: false)

        self.topLabel.font = GZEConstants.Font.main
        self.topLabel.textColor = .black

        self.bottomActionView.accessoryButton.setImage(#imageLiteral(resourceName: "button-plus"), for: .normal)
        self.bottomActionView.accessoryButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 5, bottom: 6, right: 5)
    }

    private func setupBindings() {

        self.viewModel.error.signal.skipNil().observeValues {
            GZEAlertService.shared.showBottomAlert(text: $0)
        }

        self.viewModel.loading
            .producer
            .startWithValues {[weak self] loading in
                guard let this = self else {return}
                if loading {
                    this.showLoading()
                } else {
                    this.hideLoading()
                }
            }

        self.topLabel.reactive.isHidden <~ self.viewModel.topLabelHidden
        self.topLabel.reactive.text <~ self.viewModel.topLabelText

        self.topSliderContainer.reactive.isHidden <~ self.viewModel.topSliderHidden

        self.bottomActionView.mainButton.reactive.title <~ self.viewModel.bottomButtonTitle

        // signals
        self.viewModel.dismissSignal.observeValues{[weak self] in
            self?.onDismissTapped?()
        }

        self.viewModel.ratingViewSignal.observeValues{[weak self] in
            self?.showRatingView()
        }

        // actions
        self.viewModel.bottomButtonAction
            .producer
            .startWithValues{[weak self] in
                guard let this = self else {return}
                this.bottomActionView.mainButton.reactive.pressed = $0
            }
    }
    
    func showRatingView() {
        log.debug("Trying to show view...")
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        if let view = mainStoryboard.instantiateViewController(withIdentifier: "ratingControllerId") as? GZERatingsViewController {

            log.debug("view instantiated. Setting up its view model")
            view.viewModel = self.viewModel.ratingViewModel
            self.present(view, animated: true)
        } else {
            log.error("Unable to instantiate ViewController")
            GZEAlertService.shared.showBottomAlert(text: GZERepositoryError.UnexpectedError.localizedDescription)
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

    deinit {
        log.debug("\(self) disposed")
    }
}
