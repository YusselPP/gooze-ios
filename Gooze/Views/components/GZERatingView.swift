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

    var showInfoLabel = true {
        didSet {
            self.infoLabel.isHidden = !self.showInfoLabel
        }
    }
    private let ratingView = FloatRatingView()
    let infoLabel = GZELabel()

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
            if self.showInfoLabel {
                self.infoLabel.isHidden = false
            }
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
        self.infoLabel.text = infoLabelText
        self.infoLabel.adjustsFontSizeToFitWidth = true
        self.infoLabel.minimumScaleFactor = 0.5

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
        self.leadingAnchor.constraint(equalTo: ratingView.leadingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: infoLabel.leadingAnchor, constant: -8).isActive = true
        self.trailingAnchor.constraint(equalTo: ratingView.trailingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: infoLabel.trailingAnchor, constant: 8).isActive = true
    }
}

extension Reactive where Base: GZERatingView {
    var rating: BindingTarget<Float?> {
        return makeBindingTarget {
            $0.setRating($1)
        }
    }
}
