//
//  GZEActionAlertView.swift
//  Gooze
//
//  Created by Yussel on 3/28/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEActionAlertView: UIView {

    var text: String {
        set(text) {
            self.alertView.text = text
        }
        get {
            return self.alertView.text
        }
    }

    let alertView = GZEValidationErrorView()

    let actionsView = UIStackView()

    let dismissButton = UIButton()

    init() {
        super.init(frame: CGRect.zero)
        self.initialize()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    func initialize() {

        self.dismissButton.backgroundColor = .white
        self.dismissButton.setTitle("Ok", for: .normal)
        self.dismissButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)

        self.actionsView.axis = .horizontal
        self.actionsView.distribution = .fillEqually
        self.actionsView.addArrangedSubview(self.dismissButton)


        self.addSubview(self.alertView)
        self.addSubview(self.actionsView)

        // Constraints
        self.translatesAutoresizingMaskIntoConstraints = false
        self.alertView.translatesAutoresizingMaskIntoConstraints = false
        self.actionsView.translatesAutoresizingMaskIntoConstraints = false

        self.topAnchor.constraint(equalTo: self.alertView.topAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.alertView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.alertView.trailingAnchor).isActive = true
        self.alertView.heightAnchor.constraint(equalTo: self.alertView.textLabel.heightAnchor, constant: 20).isActive = true

        self.alertView.bottomAnchor.constraint(equalTo: self.actionsView.topAnchor).isActive = true

        self.leadingAnchor.constraint(equalTo: self.actionsView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.actionsView.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.actionsView.bottomAnchor).isActive = true
        self.actionsView.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }

    func show() {
        UIView.animate(withDuration: 0.5) {[weak self] in
            self?.alpha = 1
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.5) {[weak self] in
            self?.alpha = 0
        }
    }
}
