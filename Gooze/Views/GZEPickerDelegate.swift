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

    var width: CGFloat = 200
    var titles: [[String?]]
    var elements: [[T?]]

    let selectedElements = MutableProperty<[T?]>([T?]())


    init(titles: [[String?]], elements: [[T?]]) {
        self.titles = titles
        self.elements = elements
        super.init()
        log.debug("\(self) init")

        //self.selectedElements.value = [T?].init(repeating: nil, count: self.elements.count)
        // Autoselect first element of each component
        self.selectedElements.value = self.elements.map{ $0.first.flatMap{$0} }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard component < titles.count && row < titles[component].count else { return nil }

        return titles[component][row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        log.debug("picker view, selected row: \(row), component: \(component)")

        guard component < elements.count && row < elements[component].count else { return }

        selectedElements.value[component] = elements[component][row]

        log.debug("selected value: \(String(describing: selectedElements.value))")
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return width
    }


    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}