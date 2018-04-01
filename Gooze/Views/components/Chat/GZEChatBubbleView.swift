//
//  GZEChatBubbleView.swift
//  Gooze
//
//  Created by Yussel on 3/30/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEChatBubbleView: UIView {

    let bubbleImageView = UIImageView()
    let textLabel = UILabel()
    var bubbleLeadingConstraint: NSLayoutConstraint!
    var bubbleTrailingConstraint: NSLayoutConstraint!

    var text: String? {
        didSet {
            self.textLabel.text = self.text
        }
    }

    enum Style {
        case sent
        case received
    }

    var style: Style = .sent {
        didSet {
            switch self.style {
            case .sent:
                self.changeImage(#imageLiteral(resourceName: "chat-bubble-sent"))
                self.bubbleImageView.tintColor = UIColor(white: 1, alpha: 0.9)
                self.bubbleLeadingConstraint.isActive = false
                self.bubbleTrailingConstraint.isActive = true
            case .received:
                self.changeImage(#imageLiteral(resourceName: "chat-bubble-received"))
                self.bubbleImageView.tintColor = UIColor(white: 1, alpha: 0.7)
                self.bubbleTrailingConstraint.isActive = false
                self.bubbleLeadingConstraint.isActive = true
            }
        }
    }


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

        self.backgroundColor = .clear
        self.textLabel.textColor = GZEConstants.Color.mainTextColor
        self.textLabel.numberOfLines = 0

        self.bubbleImageView.addSubview(self.textLabel)
        self.addSubview(self.bubbleImageView)

        // Constraints
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.bubbleImageView.translatesAutoresizingMaskIntoConstraints = false


        self.bubbleImageView.topAnchor.constraint(equalTo: self.textLabel.topAnchor, constant: -10).isActive = true
        self.bubbleImageView.bottomAnchor.constraint(equalTo: self.textLabel.bottomAnchor, constant: 10).isActive = true
        self.bubbleImageView.leadingAnchor.constraint(equalTo: self.textLabel.leadingAnchor, constant: -15).isActive = true
        self.bubbleImageView.trailingAnchor.constraint(equalTo: self.textLabel.trailingAnchor, constant: 15).isActive = true

        self.topAnchor.constraint(equalTo: self.bubbleImageView.topAnchor, constant: -5).isActive = true
        self.bottomAnchor.constraint(equalTo: self.bubbleImageView.bottomAnchor, constant: 5).isActive = true

        self.bubbleImageView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 0.6).isActive = true

        self.bubbleLeadingConstraint = self.leadingAnchor.constraint(equalTo: self.bubbleImageView.leadingAnchor)
        self.bubbleTrailingConstraint = self.trailingAnchor.constraint(equalTo: self.bubbleImageView.trailingAnchor)
    }

    private func changeImage(_ image: UIImage) {
        self.bubbleImageView.image = image
            .resizableImage(
                withCapInsets: UIEdgeInsetsMake(15, 18, 15, 18),
                resizingMode: .stretch
            )
            .withRenderingMode(.alwaysTemplate)
	}

}
