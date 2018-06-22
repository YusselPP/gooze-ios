//
//  GZECheckListItem.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/20/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

class GZECheckListItem: Hashable {
    let index: Int
    let label: String
    let checked: Bool
    let onChange: HandlerBlock<Bool>?

    init(index: Int, label: String, checked: Bool = false, onChange: HandlerBlock<Bool>? = nil) {
        self.index = index
        self.label = label
        self.checked = checked
        self.onChange = onChange
    }

    //Hashable
    var hashValue: Int {
        return self.label.hashValue
    }

    // MARK: Equatable
    public static func ==(lhs: GZECheckListItem, rhs: GZECheckListItem) -> Bool {
        log.debug("equals called \(lhs.label) \(rhs.label)")
        return lhs.label == rhs.label
    }
}
