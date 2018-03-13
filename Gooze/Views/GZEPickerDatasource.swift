//
//  GZEPickerDatasource.swift
//  Gooze
//
//  Created by Yussel on 3/9/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEPickerDatasource<T>: NSObject, UIPickerViewDataSource {

    var elements: [[T?]]

    // MARK - init
    init(elements: [[T?]]) {
        self.elements = elements
        super.init()
        log.debug("\(self) init")
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return elements.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard component < elements.count else { return 0 }
        return elements[component].count
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
