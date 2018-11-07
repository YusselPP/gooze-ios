//
//  GZENavButton.swift
//  Gooze
//
//  Created by Yussel on 2/24/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZENavButton: UIBarButtonItem {
    let button = UIButton(type: .custom)

    var onButtonTapped: ((UIButton) -> ())?

    override init() {
        super.init()
        log.debug("\(self) init")
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: UIControl.Event.touchUpInside)
        customView = button
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func buttonTapped(_ sender: UIButton) {
        onButtonTapped?(sender)
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
