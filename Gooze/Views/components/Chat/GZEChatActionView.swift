//
//  GZEChatActionView.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/15/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEChatActionView: UIView {

    let mainButton = GZEButton()
    let accessoryButton = UIButton()
    let titlePadding: CGFloat = 5
    
    var accessoryButtonWidth: CGFloat = 20 {
        didSet {
            self.accessoryWidthConstraint.constant = self.accessoryButtonWidth
            self.mainButton.titleEdgeInsets.left = titlePadding + self.accessoryButtonWidth
        }
    }

    lazy var accessoryWidthConstraint: NSLayoutConstraint = {
        return self.accessoryButton.widthAnchor.constraint(equalToConstant: self.accessoryButtonWidth)
    }()

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
        layer.borderWidth = 1
        layer.borderColor = GZEConstants.Color.mainGreen.cgColor
        layer.cornerRadius = 5
        layer.masksToBounds = true
        backgroundColor = GZEConstants.Color.buttonBackground

        log.debug("\(mainButton.contentEdgeInsets) \(mainButton.titleEdgeInsets)")
        
        mainButton.setTextFont(GZEConstants.Font.main)
        accessoryButton.setTextFont(GZEConstants.Font.main)
        
        mainButton.tintColor = GZEConstants.Color.mainTextColor
        accessoryButton.tintColor = GZEConstants.Color.mainTextColor
        
        mainButton.backgroundColor = .clear
        accessoryButton.backgroundColor = .clear

        mainButton.titleEdgeInsets.right = titlePadding
        mainButton.titleEdgeInsets.left = titlePadding + accessoryButtonWidth
        mainButton.maxWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) - accessoryButtonWidth * 2 - 20
        mainButton.minWidth = 180 - accessoryButtonWidth * 2
        
        accessoryButton.setImage(#imageLiteral(resourceName: "chat-send-amount") ,for: .normal)
        accessoryButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 5)
        
        addSubview(mainButton)
        addSubview(accessoryButton)
        
        // Constraints
        translatesAutoresizingMaskIntoConstraints = false
        mainButton.translatesAutoresizingMaskIntoConstraints = false
        accessoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        topAnchor.constraint(equalTo: mainButton.topAnchor).isActive = true
        topAnchor.constraint(equalTo: accessoryButton.topAnchor).isActive = true
        
        bottomAnchor.constraint(equalTo: mainButton.bottomAnchor).isActive = true
        bottomAnchor.constraint(equalTo: accessoryButton.bottomAnchor).isActive = true
        
        leadingAnchor.constraint(equalTo: mainButton.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: accessoryButton.trailingAnchor).isActive = true
        
        mainButton.trailingAnchor.constraint(equalTo: accessoryButton.leadingAnchor).isActive = true
        
        accessoryWidthConstraint.isActive = true
    }
}
