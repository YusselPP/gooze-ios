//
//  GZEPaymentCellModel.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/14/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEPaymentCellModel: NSObject {
    let type: CellType
    let isSelection: Bool
    let title: String?
    let icon: UIView?
    let onTap: HandlerBlock<GZEPaymentCollectionViewCell>?

    init(type: CellType = .element, isSelection: Bool = false, title: String? = nil, icon: UIView? = nil, onTap: HandlerBlock<GZEPaymentCollectionViewCell>? = nil) {
        self.type = type
        self.isSelection = isSelection
        self.title = title
        self.icon = icon
        self.onTap = onTap
    }

    enum CellType {
        case element
        case add
    }
}
