//
//  GZEChatsOpenView.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/23/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEChatsOpenView: UIView {

    let button = UIButton(type: .custom)

    var onTap: CompletionBlock?

    // MARK - init
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

    private func initialize() {
        self.button.setImage(#imageLiteral(resourceName: "open-chat-button"), for: .normal)
        self.button.contentEdgeInsets = UIEdgeInsets(top: 23.5, left: 5, bottom: 23.5, right: 5)
        self.button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        self.addSubview(self.button)

        // Constraints
        self.button.translatesAutoresizingMaskIntoConstraints = false

        self.topAnchor.constraint(equalTo: self.button.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.button.bottomAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.button.trailingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.button.leadingAnchor).isActive = true
    }

    @objc func handleTap() {
        self.onTap?()
    }
}
