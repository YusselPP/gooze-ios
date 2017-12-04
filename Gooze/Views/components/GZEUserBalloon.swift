//
//  GZEUserBalloon.swift
//  Gooze
//
//  Created by Yussel on 12/4/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

class GZEUserBalloon: UIView {

    var imageUrl: String?
    var rating: Float?

    var imageView = UIImageView()
    var ratingView = UIView()

    var imageViewHeightConstraint: NSLayoutConstraint!
    var imageViewWidthConstraint: NSLayoutConstraint!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        alpha = 0
        layer.masksToBounds = true
        
        // Set image view
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false


        // Set rating View
        ratingView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        addSubview(ratingView)

        setConstraints()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        imageViewHeightConstraint = heightAnchor.constraint(equalTo: superview!.heightAnchor, multiplier: 0.25)
        imageViewWidthConstraint = widthAnchor.constraint(equalTo: superview!.widthAnchor, multiplier: 0.25)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let bounds = superview?.bounds {

            if bounds.width < bounds.height {
                imageViewHeightConstraint.isActive = false
                imageViewWidthConstraint.isActive = true
            } else {
                imageViewWidthConstraint.isActive = false
                imageViewHeightConstraint.isActive = true
            }
        }
        layer.cornerRadius = bounds.width / 2
    }

    func setVisible(_ visible: Bool) {
        UIView.animate(withDuration: 0.3, animations: { [unowned self] in
            if visible {
                self.alpha = 1
            } else {
                self.alpha = 0
            }
        })
    }

    private func setConstraints() {
        topAnchor.constraint(equalTo: imageView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: imageView.trailingAnchor).isActive = true

        bottomAnchor.constraint(equalTo: ratingView.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: ratingView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: ratingView.trailingAnchor).isActive = true

        imageView.bottomAnchor.constraint(equalTo: ratingView.topAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8).isActive = true
    }
}
