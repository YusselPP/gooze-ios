//
//  GZEUserBalloon.swift
//  Gooze
//
//  Created by Yussel on 12/4/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import AlamofireImage

class GZEUserBalloon: UIView {

    static var userPlaceholder = UIImage(imageLiteralResourceName: "user-placeholder")
    var userConvertible: GZEUserConvertible?
    var user: GZEChatUser?
    var rating: Float? {
        didSet {
            starsView.setRating(rating)
        }
    }

    var onTap: ((UITapGestureRecognizer, GZEUserBalloon) -> ())?

    private var imageView = UIImageView()
    private var starsView = GZERatingView()
    private var ratingView = UIView()

    private var imageViewHeightConstraint: NSLayoutConstraint?
    private var imageViewWidthConstraint: NSLayoutConstraint?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initProperties()
    }

    init() {
        super.init(frame: CGRect.zero)
        initProperties()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        log.debug("awakeFromNib")
        imageViewHeightConstraint = heightAnchor.constraint(equalTo: superview!.heightAnchor, multiplier: 0.25)
        imageViewWidthConstraint = widthAnchor.constraint(equalTo: superview!.widthAnchor, multiplier: 0.25)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let bounds = superview?.bounds {
            if bounds.width < bounds.height {
                imageViewHeightConstraint?.isActive = false
                imageViewWidthConstraint?.isActive = true
            } else {
                imageViewWidthConstraint?.isActive = false
                imageViewHeightConstraint?.isActive = true
            }
        }
        layer.cornerRadius = bounds.width / 2
    }

    func initProperties() {
        alpha = 0
        layer.masksToBounds = true

        // Set image view
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = GZEConstants.Color.buttonBackground
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false


        // Set rating View
        ratingView.backgroundColor = nil
        ratingView.translatesAutoresizingMaskIntoConstraints = false


        ratingView.addSubview(starsView)
        addSubview(imageView)
        addSubview(ratingView)

        setConstraints()

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
    }

    func setUser(_ user: GZEUserConvertible?, completion: ( () -> ())? = nil) {

        log.debug("setting user: \(String(describing: user))")
        log.debug("user json: \(String(describing: user?.getUser().toJSON()))")
        self.user = user?.getUser()
        self.userConvertible = user

        if let user = self.user {
            self.rating = user.overallRating
            self.setImage(urlRequest: user.searchPic?.urlRequest, completion: completion)
        } else {
            log.error("Empty user set. Hidding balloon")
            self.rating = nil
            self.imageView.image = nil
            self.setVisible(false)
            completion?()
        }
    }

    func setImage(urlRequest: URLRequest?, completion: ( () -> ())? = nil){
        if let urlRequest = urlRequest {
//            imageView.af_setImage(withURLRequest: urlRequest, placeholderImage: GZEUserBalloon.userPlaceholder, completion: { _ in
//                //self?.setVisible(true)
//                completion?()
//            })
            imageView.af_setImage(withURLRequest: urlRequest, placeholderImage: GZEUserBalloon.userPlaceholder, filter: NoirFilter()){ _ in
                //self?.setVisible(true)
                completion?()
            }
        } else {
            log.error("Failed to set image url for user id=[\(String(describing: self.user?.id))]")
            imageView.image = GZEUserBalloon.userPlaceholder
            //setVisible(true)
            completion?()
        }
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

        // imageView.bottomAnchor.constraint(equalTo: ratingView.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true

        ratingView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.25).isActive = true


        starsView.widthAnchor.constraint(equalTo: ratingView.widthAnchor, multiplier: 0.65).isActive = true
        starsView.heightAnchor.constraint(equalTo: ratingView.heightAnchor, multiplier: 0.65).isActive = true

        ratingView.centerXAnchor.constraint(equalTo: starsView.centerXAnchor).isActive = true
        ratingView.centerYAnchor.constraint(equalTo: starsView.centerYAnchor).isActive = true
    }

    func tap(_ gestureRecognizer : UITapGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            onTap?(gestureRecognizer, self)
        }
    }
}
