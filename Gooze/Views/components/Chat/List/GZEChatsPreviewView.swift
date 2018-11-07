//
//  GZEChatsPreviewView.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/23/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEChatsPreviewView: UIView {

    let container = UIView()
    let title = UILabel()
    let preview = UILabel()
    let lockButton = UIButton(type: .custom)
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
        self.title.textColor = GZEConstants.Color.mainTextColor
        self.title.font = GZEConstants.Font.mainBig
        self.title.numberOfLines = 1

        self.preview.textColor = GZEConstants.Color.mainTextColor
        self.preview.font = GZEConstants.Font.main
        self.preview.numberOfLines = 2

        self.lockButton.setImage(#imageLiteral(resourceName: "lock"), for: .normal)
        self.lockButton.contentEdgeInsets = UIEdgeInsets(top: 1, left: 5, bottom: 1, right: 5)

        self.tapButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        self.container.addSubview(self.title)
        self.container.addSubview(self.preview)
        self.container.addSubview(self.lockButton)
        self.addSubview(self.container)
        self.addSubview(self.tapButton)

        // Constraints
        self.container.translatesAutoresizingMaskIntoConstraints = false
        self.title.translatesAutoresizingMaskIntoConstraints = false
        self.preview.translatesAutoresizingMaskIntoConstraints = false
        self.lockButton.translatesAutoresizingMaskIntoConstraints = false
        self.tapButton.translatesAutoresizingMaskIntoConstraints = false

        // superview -> tapButton
        self.leadingAnchor.constraint(equalTo: self.tapButton.leadingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: self.tapButton.topAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.tapButton.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.tapButton.bottomAnchor).isActive = true
        // superview -> container
        self.leadingAnchor.constraint(equalTo: self.container.leadingAnchor, constant: -5).isActive = true
        self.topAnchor.constraint(equalTo: self.container.topAnchor, constant: -5).isActive = true
        self.trailingAnchor.constraint(equalTo: self.container.trailingAnchor, constant: 5).isActive = true
        self.bottomAnchor.constraint(equalTo: self.container.bottomAnchor, constant: 5).isActive = true
        // container -> title
        self.container.leadingAnchor.constraint(equalTo: self.title.leadingAnchor).isActive = true
        self.container.topAnchor.constraint(equalTo: self.title.topAnchor).isActive = true
        // container -> preview
        self.container.leadingAnchor.constraint(equalTo: self.preview.leadingAnchor).isActive = true
        self.container.bottomAnchor.constraint(equalTo: self.preview.bottomAnchor).isActive = true
        self.container.trailingAnchor.constraint(equalTo: self.preview.trailingAnchor).isActive = true
        // container -> lockButton
        self.container.trailingAnchor.constraint(equalTo: self.lockButton.trailingAnchor).isActive = true
        self.container.topAnchor.constraint(equalTo: self.lockButton.topAnchor).isActive = true

        // title, lockbutton, preview
        self.title.trailingAnchor.constraint(equalTo: self.lockButton.leadingAnchor, constant: 5).isActive = true
        self.title.bottomAnchor.constraint(equalTo: self.preview.topAnchor).isActive = true
        self.preview.topAnchor.constraint(equalTo: self.lockButton.bottomAnchor).isActive = true

        self.lockButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        self.lockButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }

    @objc func handleTap() {
        self.onTap?()
    }

}
