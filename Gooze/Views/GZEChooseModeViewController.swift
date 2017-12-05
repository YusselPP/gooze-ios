//
//  GZEChooseModeViewController.swift
//  Gooze
//
//  Created by Yussel on 11/20/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

class GZEChooseModeViewController: UIViewController {

    var viewModel: GZEChooseModeViewModel!

    var goozeScene = GZEActivateGoozeViewController.Scene.search
    let activateGoozeSegueId = "activateGoozeSegueId"

    let closeHelpButton = UIBarButtonItem()
    let logoutButton = GZELogoutButton()

    let beButton = UIButton()
    let searchButton = UIButton()

    @IBOutlet weak var showHelpButton: UIButton!

    @IBOutlet weak var goozeHelpLabel: UILabel!
    @IBOutlet weak var clientHelpLabel: UILabel!

    @IBOutlet weak var middleYConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomYConstraint: NSLayoutConstraint!

    @IBOutlet weak var doubleCtrlView: GZEDoubleCtrlView!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        logoutButton.target = self
        logoutButton.action = #selector(logoutButtonTapped(_:))

        closeHelpButton.title = "X"
        closeHelpButton.target = self
        closeHelpButton.action = #selector(closeHelpButtonTapped(_:))

        goozeHelpLabel.text = viewModel.goozeHelpLabelText
        clientHelpLabel.text = viewModel.clientHelpLabelText

        beButton.enableAnimationOnPressed()
        searchButton.enableAnimationOnPressed()

        beButton.setTitle(viewModel.beButtonTitle.uppercased(), for: .normal)
        searchButton.setTitle(viewModel.searchButtonTitle.uppercased(), for: .normal)

        beButton.addTarget(self, action: #selector(beButtonTapped(_:)), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonTapped(_:)), for: .touchUpInside)

        doubleCtrlView.topViewTappedHandler = { [unowned self] _ in
            self.beButton.sendActions(for: .touchUpInside)
        }
        doubleCtrlView.bottomViewTappedHandler = { [unowned self] _ in
            self.searchButton.sendActions(for: .touchUpInside)
        }

        doubleCtrlView.topCtrlView = beButton
        doubleCtrlView.bottomCtrlView = searchButton

        showHelp(false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func beButtonTapped(_ sender: Any) {
        goozeScene = .activate
        performSegue(withIdentifier: activateGoozeSegueId, sender: self)
    }

    func searchButtonTapped(_ sender: Any) {
        goozeScene = .search
        performSegue(withIdentifier: activateGoozeSegueId, sender: self)
    }

    @IBAction func helpButtonTapped(_ sender: UIButton) {
        showHelp(true)
    }

    func closeHelpButtonTapped(_ sender: UIButton) {
        showHelp(false)
    }

    func showHelp(_ show: Bool) {
        UIView.animate(withDuration: 0.5) { [unowned self] in
            if show == true {
                self.bottomYConstraint.isActive = false
                self.middleYConstraint.isActive = true
                self.goozeHelpLabel.alpha = 1
                self.clientHelpLabel.alpha = 1
                self.closeHelpButton.customView?.alpha = 1
                self.showHelpButton.alpha = 0
                self.navigationItem.leftBarButtonItem = self.closeHelpButton
            } else {
                self.middleYConstraint.isActive = false
                self.bottomYConstraint.isActive = true
                self.goozeHelpLabel.alpha = 0
                self.clientHelpLabel.alpha = 0
                self.closeHelpButton.customView?.alpha = 0
                self.showHelpButton.alpha = 1
                self.navigationItem.leftBarButtonItem = self.logoutButton
            }
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == activateGoozeSegueId {

            if let viewController = segue.destination as? GZEActivateGoozeViewController {
                viewController.viewModel = viewModel.getActivateGoozeViewModel()
                viewController.scene = goozeScene
            } else {
                log.error("Unable to instantiate GZEActivateGoozeViewController")
                displayMessage(nil, GZERepositoryError.UnexpectedError.localizedDescription)
            }
        }
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }

}
