//
//  GZEChatsPhotoView.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/23/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEChatsPhotoView: UIView {

    let balloon = GZEUserBalloon()
    let tapButton = UIButton(type: .custom)

    var onTap: CompletionBlock?

    // MARK - init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    init() {
        super.init(frame: CGRect.zero)
        initialize()
    }

    private func initialize() {
        self.tapButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        
        self.addSubview(self.balloon)
        self.addSubview(self.tapButton)

        // constraints
        self.balloon.translatesAutoresizingMaskIntoConstraints = false
        self.tapButton.translatesAutoresizingMaskIntoConstraints = false

        self.balloon.widthAnchor.constraint(equalTo: self.balloon.heightAnchor).isActive = true

        // self.topAnchor.constraint(equalTo: self.balloon.topAnchor).isActive = true
        // self.bottomAnchor.constraint(equalTo: self.balloon.bottomAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: self.balloon.centerYAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.balloon.leadingAnchor, constant: -8).isActive = true
        self.trailingAnchor.constraint(equalTo: self.balloon.trailingAnchor, constant: 5).isActive = true

        self.topAnchor.constraint(equalTo: self.tapButton.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.tapButton.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.tapButton.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.tapButton.trailingAnchor).isActive = true
    }

    @objc func handleTap() {
        self.onTap?()
    }
}
