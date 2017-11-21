//
//  GZETextField.swift
//  Gooze
//
//  Created by Yussel on 11/12/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift

class GZETextField: UITextField {
    
    var validationFeedbackLabel: UILabel?
    var model: MutableProperty<String?>?
    var isValid = MutableProperty<Bool>(true)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        log.debug("\(self) init")
        initProperties()
    }

    func initProperties() {
        layer.cornerRadius = 5
        layer.borderWidth = 0
        layer.borderColor = UIColor.red.cgColor

        validationHandler = { [weak self] result in
            switch result {
            case .valid:
                self?.validationFeedbackLabel?.text = nil
                self?.layer.borderWidth = 0
                self?.isValid.value = true
            case .invalid(let failureErrors):
                log.debug(failureErrors)
                self?.layer.borderWidth = 1
                self?.validationFeedbackLabel?.text = failureErrors.first?.localizedDescription
                self?.isValid.value = false
            }
        }

        reactive.continuousTextValues.observeValues { [weak self] in
            self?.model?.value = $0
            self?.validationFeedbackLabel?.text = nil
            self?.layer.borderWidth = 0
        }
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
