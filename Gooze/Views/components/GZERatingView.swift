//
//  GZERatingView.swift
//  Gooze
//
//  Created by Yussel on 3/7/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import FloatRatingView
import ReactiveSwift

class GZERatingView: UIView {

    private let ratingView = FloatRatingView()
    private let infoLabel = GZELabel()

    private let infoLabelText = "vm.ratingView.unrated".localized()

    init() {
        super.init(frame: CGRect.zero)
        initProperties()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initProperties()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initProperties()
    }

    public func setRating(_ rating: Float?) {
        if let rating = rating {
            self.ratingView.rating = rating
            self.ratingView.isHidden = false
            self.infoLabel.isHidden = true
        } else {
            self.ratingView.isHidden = true
            self.infoLabel.isHidden = false
        }
    }

    public func setEditable(_ editable: Bool) {
        self.ratingView.editable = editable
    }

    private func initProperties() {

        self.ratingView.fullImage = #imageLiteral(resourceName: "white-star")
        self.ratingView.emptyImage = #imageLiteral(resourceName: "white-star-empty")
        self.ratingView.floatRatings = true
        self.ratingView.editable = false
        self.ratingView.contentMode = .scaleAspectFit
        self.ratingView.isHidden = true

        // infoLabel
        self.infoLabel.setWhiteFontFormat()
        self.infoLabel.textAlignment = .natural
        self.infoLabel.text = infoLabelText

        // GZERatingView
        self.backgroundColor = nil
        self.clipsToBounds = true


        self.addSubview(infoLabel)
        self.addSubview(ratingView)

        // constraints
        self.ratingView.translatesAutoresizingMaskIntoConstraints = false
        self.infoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false

        self.topAnchor.constraint(equalTo: ratingView.topAnchor).isActive = true
        self.topAnchor.constraint(equalTo: infoLabel.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: ratingView.bottomAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: infoLabel.bottomAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: ratingView.leftAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: infoLabel.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: ratingView.rightAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: infoLabel.rightAnchor).isActive = true
    }
}

extension Reactive where Base: GZERatingView {
    var rating: BindingTarget<Float?> {
        return makeBindingTarget {
            $0.setRating($1)
        }
    }
}
