//
//  GZECardNumber.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/27/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Validator

class GZECardNumber: GZEFloatingLabelTextField, UITextFieldDelegate {
    let cardIcon = "\u{f09d}"
    let mcIcon = "\u{f1f1}"
    let visaIcon = "\u{f1f0}"

    let cardNumberText = "text.field.card.number".localized().uppercased()

    let mcRegexPattern = "^(5[1-5])|^(2(?:2(?:2[1-9]|[3-9])|[3-6]|7(?:[01]|20)))"
    let visaRegexPattern = "^4"

    let normalizedText = MutableProperty<String?>(nil)

    private var previousRange: UITextRange?

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
        log.debug("\(self) init")
        self.delegate = self
        self.iconText = self.cardIcon
        self.title = self.cardNumberText
        self.selectedTitle = self.cardNumberText
        self.placeholder = self.cardNumberText
        self.keyboardType = .numberPad
        self.autocorrectionType = .no
        self.errorColor = GZEConstants.Color.errorMessage

        self.addValidation()

        self.normalizedText <~ self.reactive.continuousTextValues.map {$0?.cardNumberFormat(reverse: true)}

        self.reactive.iconText <~ self.normalizedText.map {[weak self] in
            return self?.updateBranchIcon($0)
        }

        self.reactive.continuousTextValues.observeValues {[weak self] in
            self?.applyFormat($0)
        }
    }

    func updateBranchIcon(_ cardNumber: String?) -> String {
        guard let cardNumber = cardNumber else {
            return self.cardIcon
        }

        if cardNumber.matches(pattern: self.mcRegexPattern) {
            return self.mcIcon
        } else if cardNumber.matches(pattern: self.visaRegexPattern) {
            return self.visaIcon
        } else {
            return self.cardIcon
        }
    }

    func applyFormat(_ text: String?) {
//        log.debug("\(self.selectedTextRange)")
        let formattedText = text?.cardNumberFormat()
        // let lenDiff = (formattedText?.count ?? 0) - (text?.count ?? 0)
//        let range = self.selectedTextRange
//        let lenDiff = self.numOfSpacesBefore(range) - self.numOfSpacesBefore(self.previousRange)
//        var newRange: UITextRange?
//        if
//            self.isBeforeSpace(self.previousRange),
//            self.isAfterSpace(range)
//        {
//            newRange = self.textRange(from: range, to: )
//        }
//        log.debug("lenDiff: \(lenDiff)")
        self.text = formattedText
//        if
//            let range = range,
//            let newStart = self.position(from: range.start, offset: lenDiff),
//            let newEnd = self.position(from: range.end, offset: lenDiff)
//        {
//            DispatchQueue.main.async {
//                log.debug("\(self.selectedTextRange)")
//                self.selectedTextRange = self.textRange(from: newStart, to: newEnd)
//                log.debug("\(self.selectedTextRange)")
//            }
//        }
    }

    func numOfSpacesBefore(_ range: UITextRange?) -> Int {
        guard let range = range else {return 0}
        let pos = self.rangePosition(range)
        return pos / 5 - 1
    }

    func addValidation() {
        self.validationRules = ValidationRuleSet(rules: [
            GZECardNumberValidation(acceptedTypes: [.mastercard, .visa], error: GZEValidationError.invalidCardNumber)
        ])
        self.validateOnEditingEnd(enabled: true)
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.previousRange = self.selectedTextRange
        return true
    }

    // MARK: - deinit
    deinit {
        log.debug("\(self) disposed")
    }
}

extension Reactive where Base: GZECardNumber {
    var iconText: BindingTarget<String?> {
        return makeBindingTarget {
            $0.iconText = $1
        }
    }

    var text: BindingTarget<String?> {
        return makeBindingTarget {
            $0.applyFormat($1)
        }
    }
}


