//
//  DismissView.swift
//  Gooze
//
//  Created by Yussel on 3/26/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class DismissView: UIView {

    // MARK: - public vars
    let label = UILabel()


    // MARK: - private vars


    // MARK: - init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        log.debug("\(self) init")
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        log.debug("\(self) init")
        initialize()
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }


    // MARK: - Public methods


    // MARK: - Private methods
    private func initialize() {
        self.translatesAutoresizingMaskIntoConstraints = false

        label.text = "X"
        label.textColor = .darkGray
        label.font = GZEConstants.Font.main
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)

        // Constraints
        self.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
