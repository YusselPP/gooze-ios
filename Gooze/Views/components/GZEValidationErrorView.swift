//
//  GZEValidationErrorView.swift
//  Gooze
//
//  Created by Yussel on 3/24/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEValidationErrorView: UIView {

    open var text: String = "" {
        didSet {
            self.textLabel.text = self.text
            UIView.animate(withDuration: 0.5) {
                self.alpha = 1
            }
        }
    }

    private let discardButton = UIView()
    private let textView = UIView()
    private let textLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    open func dismiss() {
        UIView.animate(withDuration: 0.5) {[weak self] in
            self?.alpha = 0
        }
    }

    private func initialize() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.discardButton.translatesAutoresizingMaskIntoConstraints = false
        self.textView.translatesAutoresizingMaskIntoConstraints = false


        self.alpha = 0
        self.backgroundColor = GZEConstants.Color.validationErrorViewBg
        self.discardButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))

        let label = UILabel()
        label.text = "X"
        label.textColor = .darkGray
        label.font = GZEConstants.Font.main
        label.translatesAutoresizingMaskIntoConstraints = false
        self.discardButton.addSubview(label)


        self.textLabel.font = GZEConstants.Font.main
        self.textLabel.textAlignment = .center
        self.textLabel.numberOfLines = 2
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textView.addSubview(textLabel)


        self.addSubview(textView)
        self.addSubview(discardButton)


        // Constraints
        self.discardButton.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
        self.discardButton.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        self.discardButton.widthAnchor.constraint(equalToConstant: 60).isActive = true

        // self.textView.centerXAnchor.constraint(equalTo: textLabel.centerXAnchor).isActive = true
        self.textLabel.leadingAnchor.constraint(equalTo: discardButton.trailingAnchor).isActive = true
        self.textLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -50).isActive = true
        self.textView.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor).isActive = true

        self.leadingAnchor.constraint(equalTo: self.discardButton.leadingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.textView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.textView.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: self.discardButton.topAnchor).isActive = true
        self.topAnchor.constraint(equalTo: self.textView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.discardButton.bottomAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.textView.bottomAnchor).isActive = true
    }
}

