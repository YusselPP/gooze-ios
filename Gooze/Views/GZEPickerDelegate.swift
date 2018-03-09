//
//  GZEPickerDelegate.swift
//  Gooze
//
//  Created by Yussel on 3/9/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift

class GZEPickerDelegate<T>: NSObject, UIPickerViewDelegate {

    var titles: [[String?]]
    var elements: [[T]]

    let selectedElement = MutableProperty<T?>(nil)


    init(titles: [[String?]], elements: [[T]]) {
        self.titles = titles
        self.elements = elements
        super.init()
        log.debug("\(self) init")
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard component < titles.count && row < titles[component].count else { return nil }

        return titles[component][row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        log.debug("picker view, selected row: \(row), component: \(component)")

        guard component < elements.count && row < elements[component].count else { return }

        selectedElement.value = elements[component][row]

        log.debug("selected value: \(String(describing: selectedElement.value))")
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
