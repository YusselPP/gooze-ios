//
//  GZEChatsCloseView.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/23/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEChatsCloseView: UIView {

    let button = UIButton(type: .custom)

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
        self.backgroundColor = .gray

        self.button.setTitle("chat.list.close".localized(), for: .normal)
        self.button.setTextFont(GZEConstants.Font.main)
        self.button.setTitleColor(GZEConstants.Color.mainTextColor, for: .normal)
        self.button.setTitleColor(.darkGray, for: .highlighted)
        self.button.transform = self.button.transform.rotated(by: -CGFloat.pi / 2)
        self.button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        self.addSubview(self.button)
        
        // Constraints
        self.button.translatesAutoresizingMaskIntoConstraints = false

        self.centerXAnchor.constraint(equalTo: self.button.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: self.button.centerYAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: self.button.widthAnchor).isActive = true
        self.widthAnchor.constraint(equalTo: self.button.heightAnchor).isActive = true
    }

    func handleTap() {
        self.onTap?()
    }
}
