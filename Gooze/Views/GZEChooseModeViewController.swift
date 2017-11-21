//
//  GZEChooseModeViewController.swift
//  Gooze
//
//  Created by Yussel on 11/20/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

class GZEChooseModeViewController: UIViewController {

    let searchGoozeSegueId = "searchGoozeSegueId"

    @IBOutlet weak var gooze: UIButton!
    @IBOutlet weak var client: UIButton!

    @IBOutlet weak var closeHelpButton: UIBarButtonItem!
    @IBOutlet weak var showHelpButton: UIButton!

    @IBOutlet weak var goozeHelpLabel: UILabel!
    @IBOutlet weak var clientHelpLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        goozeHelpLabel.alpha = 0
        clientHelpLabel.alpha = 0
        closeHelpButton.customView?.alpha = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goozeButtonTapped(_ sender: Any) {

    }

    @IBAction func clientButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: searchGoozeSegueId, sender: self)
    }

    @IBAction func helpButtonTapped(_ sender: UIButton) {
        showHelp(true)
    }

    @IBAction func closeHelpButtonTapped(_ sender: UIButton) {
        showHelp(false)
    }

    func showHelp(_ show: Bool) {
        UIView.animate(withDuration: 0.3) { [weak self] in

            log.debug(show)
            if show == true {
                log.debug("show")
                self?.goozeHelpLabel.alpha = 1
                self?.clientHelpLabel.alpha = 1
                self?.closeHelpButton.customView?.alpha = 1
                self?.showHelpButton.alpha = 0
            } else {
                log.debug("hide")
                self?.goozeHelpLabel.alpha = 0
                self?.clientHelpLabel.alpha = 0
                self?.closeHelpButton.customView?.alpha = 0
                self?.showHelpButton.alpha = 1
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if
            segue.identifier == searchGoozeSegueId,
            let viewController = segue.destination as? GZESearchGoozeViewController
        {

            viewController.viewModel = GZESearchGoozeViewModel()

        }
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }

}
