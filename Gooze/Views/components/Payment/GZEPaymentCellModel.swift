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
    let swipeActionEnabled: Bool
    let onTap: HandlerBlock<GZEPaymentCollectionViewCell>?
    let onClose: HandlerBlock<GZEPaymentCollectionViewCell>?
    let isCloseShown: Bool

    init(
        type: CellType = .element,
        isSelection: Bool = false,
        title: String? = nil,
        icon: UIView? = nil,
        swipeActionEnabled: Bool = false,
        onTap: HandlerBlock<GZEPaymentCollectionViewCell>? = nil,
        onClose: HandlerBlock<GZEPaymentCollectionViewCell>? = nil,
        isCloseShown: Bool = false
    ) {
        self.type = type
        self.isSelection = isSelection
        self.title = title
        self.icon = icon
        self.swipeActionEnabled = swipeActionEnabled
        self.onTap = onTap
        self.onClose = onClose
        self.isCloseShown = isCloseShown
    }

    enum CellType {
        case element
        case add
    }
}
