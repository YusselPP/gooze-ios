//
//  GZESignUpMoreViewController.swift
//  Gooze
//
//  Created by Yussel Paredes on 10/26/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZESignUpMoreViewController: UIViewController {

    var viewModel: GZESignUpViewModel!

    let moreToPhotoSignUpSegueId = "moreToPhotoSignUpSegue"

    @IBOutlet weak var birthdayDatePicker: UIDatePicker!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var phraseTextField: UITextField!
    @IBOutlet weak var languagesTextField: UITextField!
    @IBOutlet weak var interestedInTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")
        // Do any additional setup after loading the view.
        viewModel.birthday <~ birthdayDatePicker.reactive.dates
        viewModel.gender <~ genderTextField.reactive.continuousTextValues
        viewModel.weight <~ weightTextField.reactive.continuousTextValues
        viewModel.height <~ heightTextField.reactive.continuousTextValues
        viewModel.origin <~ originTextField.reactive.continuousTextValues
        viewModel.phrase <~ phraseTextField.reactive.continuousTextValues
        viewModel.languages <~ languagesTextField.reactive.continuousTextValues
        viewModel.interestedIn <~ interestedInTextField.reactive.continuousTextValues
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
        if
            segue.identifier == moreToPhotoSignUpSegueId,
            let viewController = segue.destination as? GZESignUpPhotoViewController {

            viewController.viewModel = viewModel
        }
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
