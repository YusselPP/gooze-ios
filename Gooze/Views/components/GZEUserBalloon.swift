//
//  GZEUserBalloon.swift
//  Gooze
//
//  Created by Yussel on 12/4/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import AlamofireImage
import FloatRatingView

class GZEUserBalloon: UIView {

    var rating: Float = 0 {
        didSet {
            starsView.rating = rating
        }
    }

    var imageView = UIImageView()

    private var ratingView = UIView()
    var starsView = FloatRatingView()

    private var imageViewHeightConstraint: NSLayoutConstraint!
    private var imageViewWidthConstraint: NSLayoutConstraint!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        alpha = 0
        layer.masksToBounds = true
        
        // Set image view
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false


        // Set rating View
        ratingView.backgroundColor = .white
        ratingView.translatesAutoresizingMaskIntoConstraints = false


        starsView.fullImage = #imageLiteral(resourceName: "full-star")
        starsView.emptyImage = #imageLiteral(resourceName: "empty-star")
        starsView.floatRatings = true
        starsView.editable = false
        starsView.contentMode = .scaleAspectFit
        starsView.translatesAutoresizingMaskIntoConstraints = false


        ratingView.addSubview(starsView)
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

    func setImage(urlRequest: URLRequest, completion: ( () -> ())? = nil){
        imageView.af_setImage(withURLRequest: urlRequest, completion: { [weak self] _ in
            self?.setVisible(true)
            completion?()
        })
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


        ratingView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2).isActive = true


        starsView.widthAnchor.constraint(equalTo: ratingView.widthAnchor, multiplier: 0.5).isActive = true
        starsView.heightAnchor.constraint(equalTo: ratingView.heightAnchor, multiplier: 0.5).isActive = true

        ratingView.centerXAnchor.constraint(equalTo: starsView.centerXAnchor).isActive = true
        ratingView.centerYAnchor.constraint(equalTo: starsView.centerYAnchor).isActive = true
    }
}
