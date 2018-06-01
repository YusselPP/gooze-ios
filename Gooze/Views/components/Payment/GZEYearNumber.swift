//
//  GZEYearNumber.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/28/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZEYearNumber: GZEFloatingLabelTextField {

    let yearText = "text.field.exp.year".localized().uppercased()
    let formatPlaceholder = "YYYY"

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
        self.title = yearText
        self.keyboardType = .numberPad

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
                .prefix(4)
        )

        return normalizedString
    }

}

extension Reactive where Base: GZEYearNumber {
    var text: BindingTarget<String?> {
        return makeBindingTarget {
            $0.text = $0.format($1)
        }
    }
}
