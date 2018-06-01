//
//  GZECVC.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/28/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Validator

class GZECVC: GZEFloatingLabelTextField {

    let cvcText = "CVC"
    let formatPlaceholder = "CVC"

    let normalizedText = MutableProperty<String?>(nil)

    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        initProperties()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initProperties()
    }

    override init() {
        super.init(frame: .zero)
        initProperties()
    }

    private func initProperties() {
        self.iconWidth = 0
        self.placeholder = formatPlaceholder
        self.selectedTitle = formatPlaceholder
        self.title = cvcText
        self.keyboardType = .numberPad
        self.autocorrectionType = .no
        self.isSecureTextEntry = true
        self.titleLabel.numberOfLines = 2

        self.addValidation()

        self.normalizedText <~ self.reactive.continuousTextValues.map {[weak self] in
            return self?.format($0)
        }

        self.reactive.text <~ self.reactive.continuousTextValues
    }

    func format(_ string: String?) -> String? {
        guard let string = string else {
            return nil
        }

        log.debug("normalized: \(string)")

        let normalizedString = String(
            string.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
                .prefix(3)
        )

        return normalizedString
    }

    func addValidation() {
        self.validationRules = ValidationRuleSet(rules: [
            ValidationRuleLength(min: 3, lengthType: .characters, error: GZEValidationError.lengthMin(fieldName: "CVC", min: 3))
        ])
        //self.validateOnEditingEnd(enabled: true)
        self.validationHandler = { [weak self] result in
            switch result {
            case .valid:
                self?.errorMessage = nil
            case .invalid(let failureErrors):
                log.debug(failureErrors)
                self?.errorMessage = failureErrors.first?.localizedDescription
            }
        }

        self.reactive.controlEvents(.editingDidBegin).observeValues{[weak self] _ in
            self?.errorMessage = nil
        }
    }

}

extension Reactive where Base: GZECVC {
    var text: BindingTarget<String?> {
        return makeBindingTarget {
            $0.text = $0.format($1)
        }
    }
}
