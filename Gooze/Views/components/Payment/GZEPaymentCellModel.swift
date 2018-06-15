//
//  GZEPaymentCellModel.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/14/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEPaymentCellModel: NSObject {
    let title: String?
    let icon: UIView?
    let onTap: HandlerBlock<GZEPaymentCollectionViewCell>?

    init(title: String? = nil, icon: UIView? = nil, onTap: HandlerBlock<GZEPaymentCollectionViewCell>? = nil) {
        self.title = title
        self.icon = icon
        self.onTap = onTap
    }
}
