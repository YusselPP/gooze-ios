//
//  GZECheckListViewModel.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/20/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZECheckListViewModel {

    let title = MutableProperty<String?>(nil)
    let botRightButtonTitle = MutableProperty<String>("vm.signUp.nextButtonTitle".localized())
    let items = MutableProperty<[GZECheckListItem]?>(nil)

    // private properties
    let options: Property<[String]>
    let selectedIndexes: MutableProperty<[Int]>

    init(options: [String], selectedIndexes: MutableProperty<[Int]>, title: String = "") {

        self.options = Property(value: options)
        self.selectedIndexes = selectedIndexes
        log.debug("\(self) init")

        self.title.value = title
        self.items <~ self.selectedIndexes.combineLatest(with: self.options).map{
            (selectedIndexes, options) in

            var items = [GZECheckListItem]()
            for (index, option) in options.enumerated() {
                items.append(GZECheckListItem(
                    index: index,
                    label: option,
                    checked: selectedIndexes.contains(index),
                    onChange: {[weak self] checked in
                        guard let this = self else {return}
                        if checked {
                            this.selectedIndexes.value.append(index)
                        } else {
                            if let pos = this.selectedIndexes.value.index(where: {$0 == index}) {
                                this.selectedIndexes.value.remove(at: pos)
                            }
                        }
                    }
                ))
            }
            return items
        }
    }

    deinit {
        log.debug("\(self) disposed")
    }
}
