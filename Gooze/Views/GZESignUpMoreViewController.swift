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

class GZESignUpMoreViewController: UIViewController, UIPickerViewDelegate {

    var viewModel: GZESignUpViewModel!

    let moreToPhotoSignUpSegueId = "moreToPhotoSignUpSegue"

    @IBOutlet weak var birthdayTextField: GZETextField!
    @IBOutlet weak var genderTextField: GZETextField!
    @IBOutlet weak var weightTextField: GZETextField!
    @IBOutlet weak var heightTextField: GZETextField!
    @IBOutlet weak var originTextField: GZETextField!
    @IBOutlet weak var phraseTextField: GZETextField!
    @IBOutlet weak var languagesTextField: GZETextField!
    @IBOutlet weak var interestedInTextField: GZETextField!

    let birthdayPicker = UIDatePicker()
    let genderPicker = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        log.debug("\(self) init")

        // viewModel.gender <~ genderTextField.reactive.continuousTextValues
        viewModel.weight <~ weightTextField.reactive.continuousTextValues
        viewModel.height <~ heightTextField.reactive.continuousTextValues
        viewModel.origin <~ originTextField.reactive.continuousTextValues
        viewModel.phrase <~ phraseTextField.reactive.continuousTextValues
        viewModel.languages <~ languagesTextField.reactive.continuousTextValues
        viewModel.interestedIn <~ interestedInTextField.reactive.continuousTextValues

        birthdayTextField.reactive.text <~ birthdayPicker.reactive.dates.map { [weak self] in
            self?.viewModel.birthday.value = $0
            return GZEDateHelper.dateFormatter.string(from: $0)
        }

        birthdayPicker.datePickerMode = .date
        birthdayPicker.maximumDate = Date()
        birthdayTextField.inputView = birthdayPicker


        genderPicker.dataSource = viewModel
        genderPicker.delegate = self
        genderTextField.inputView = genderPicker

        // TODO: Validate numbers
        // TODO: validate interests
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

    // MARK: UIPickerDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.genders[row]?.rawValue
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        log.debug("picker view, selected row: \(row), gender: \(String(describing: viewModel.genders[row]))")
        viewModel.gender.value = viewModel.genders[row]
        genderTextField.text = viewModel.gender.value?.rawValue
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
