//
//  GZERegisterCodeViewController.swift
//  Gooze
//
//  Created by Yussel on 11/18/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

class GZERegisterCodeViewController: UIViewController {

    var viewModel: GZERegisterCodeViewModel!

    let signUpSegueId = "signUpSegue"

    let codeTextField = GZETextField()
    let codeLabel = UILabel()
    
    @IBOutlet weak var dblCtrlView: GZEDoubleCtrlView!

    override func viewDidLoad() {
        super.viewDidLoad()


        codeLabel.text = "Código de registro".uppercased()

        dblCtrlView.separatorWidth = 150
        dblCtrlView.topCtrlView = codeTextField
        dblCtrlView.bottomCtrlView = codeLabel
    }
    override func viewDidAppear(_ animated: Bool) {
        // registerForKeyboarNotifications(observer: self, didShowSelector: #selector(), willHideSelector: #selector())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        // TODO: Validate register code
        performSegue(withIdentifier: signUpSegueId, sender: self)
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if
            segue.identifier == signUpSegueId,
            let viewController = segue.destination as? GZESignUpBasicViewController
        {
            viewController.viewModel = viewModel.getSignUpViewModel()

        }
    }


}
