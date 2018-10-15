//
//  GZELoadingUIView.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 10/14/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZELoadingUIView: UIView {

    var containerView: UIView? {
        willSet {
            if self.containerView != nil {
                self.removeFromSuperview()
            }
        }

        didSet {
            if let containerView = self.containerView {
                containerView.addSubview(self)
                containerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            }
        }
    }
    let background = UIView()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    init() {
        super.init(frame: CGRect.zero)
        self.initialize()
    }


    func start() {
        self.alpha = 1
        self.activityIndicator.startAnimating()
    }

    func stop() {
        self.activityIndicator.stopAnimating()
        self.alpha = 0
    }

    // Private

    private func initialize() {
        self.alpha = 0
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false

        self.backgroundColor = UIColor(white: 0, alpha: 0.7)

        self.background.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.background)
        self.addSubview(self.activityIndicator)

        self.topAnchor.constraint(equalTo: self.background.topAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.background.leadingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.background.bottomAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.background.trailingAnchor).isActive = true

        self.centerXAnchor.constraint(equalTo: self.activityIndicator.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: self.activityIndicator.centerYAnchor).isActive = true
    }
}
