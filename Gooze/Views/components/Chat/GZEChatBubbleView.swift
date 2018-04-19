//
//  GZEChatBubbleView.swift
//  Gooze
//
//  Created by Yussel on 3/30/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEChatBubbleView: UIView {
    
    static let minSize: CGFloat = 57
    static let font = GZEConstants.Font.main
    static let labelPadding: CGFloat = 10
    static let bubblePadding: CGFloat = 5

    let bubbleImageView = UIImageView()
    let textLabel = UILabel()
    let fakeTextLabel = UILabel()
    var bubbleLeadingConstraint: NSLayoutConstraint!
    var bubbleTrailingConstraint: NSLayoutConstraint!
    var textLabelLeadingConstraint: NSLayoutConstraint!
    var textLabelTrailingConstraint: NSLayoutConstraint!

    var text: String? {
        didSet {
            self.textLabel.text = self.text
            self.fakeTextLabel.text = self.text
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
                self.textLabelTrailingConstraint.constant = 25
                self.textLabelLeadingConstraint.constant = -15
                self.bubbleLeadingConstraint.isActive = false
                self.bubbleTrailingConstraint.isActive = true
            case .received:
                self.changeImage(#imageLiteral(resourceName: "chat-bubble-received"))
                self.bubbleImageView.tintColor = UIColor(white: 1, alpha: 0.6)
                self.textLabelTrailingConstraint.constant = 15
                self.textLabelLeadingConstraint.constant = -25
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
        self.textLabel.textColor = GZEConstants.Color.chatBubbleTextColor
        self.textLabel.numberOfLines = 0
        self.textLabel.font = GZEChatBubbleView.font
        self.fakeTextLabel.numberOfLines = 0
        self.fakeTextLabel.textColor = .clear
        self.fakeTextLabel.font = GZEChatBubbleView.font
        

        self.bubbleImageView.addSubview(self.fakeTextLabel)
        self.addSubview(self.bubbleImageView)
        self.addSubview(self.textLabel)

        // Constraints
        self.fakeTextLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.bubbleImageView.translatesAutoresizingMaskIntoConstraints = false


        self.bubbleImageView.topAnchor.constraint(equalTo: self.fakeTextLabel.topAnchor, constant: -GZEChatBubbleView.labelPadding).isActive = true
        self.bubbleImageView.bottomAnchor.constraint(equalTo: self.fakeTextLabel.bottomAnchor, constant: GZEChatBubbleView.labelPadding).isActive = true
        
        
        self.textLabelLeadingConstraint = self.bubbleImageView.leadingAnchor.constraint(equalTo: self.fakeTextLabel.leadingAnchor)
        self.textLabelTrailingConstraint = self.bubbleImageView.trailingAnchor.constraint(equalTo: self.fakeTextLabel.trailingAnchor)
        self.textLabelLeadingConstraint.isActive = true
        self.textLabelTrailingConstraint.isActive = true
        
        self.textLabel.topAnchor.constraint(equalTo: self.fakeTextLabel.topAnchor).isActive = true
        self.textLabel.bottomAnchor.constraint(equalTo: self.fakeTextLabel.bottomAnchor).isActive = true
        self.textLabel.leadingAnchor.constraint(equalTo: self.fakeTextLabel.leadingAnchor).isActive = true
        self.textLabel.trailingAnchor.constraint(equalTo: self.fakeTextLabel.trailingAnchor).isActive = true

        self.topAnchor.constraint(equalTo: self.bubbleImageView.topAnchor, constant: -GZEChatBubbleView.bubblePadding).isActive = true
        self.bottomAnchor.constraint(equalTo: self.bubbleImageView.bottomAnchor, constant: GZEChatBubbleView.bubblePadding).isActive = true

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
