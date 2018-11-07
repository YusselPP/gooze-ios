//
//  GZEBalanceCollectionCell.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/28/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEBalanceCollectionCell: UICollectionViewCell {
    var model: GZEBalanceCellModel? {
        didSet {
            if let model = self.model {
                self.setCellModel(model)
            } else {
                self.clear()
            }
        }
    }

    var author: String? {
        set{
            self.authorLabel.text = newValue
        }
        get {
            return self.authorLabel.text
        }
    }

    var amount: String? {
        set{
            self.amountLabel.text = newValue
        }
        get {
            return self.amountLabel.text
        }
    }

    var amountColor: UIColor {
        set{
            self.amountLabel.textColor = newValue
        }
        get {
            return self.amountLabel.textColor
        }
    }

    var date: String? {
        set{
            self.dateLabel.text = newValue
        }
        get {
            return self.dateLabel.text
        }
    }

    var status: String? {
        set{
            self.statusLabel.text = newValue
        }
        get {
            return self.statusLabel.text
        }
    }

    let stackView = UIStackView()

    let leftView = UIView()
    let authorLabel = GZELabel()
    let dateLabel = GZELabel()

    let rightView = UIView()
    let amountLabel = GZELabel()
    let statusLabel = GZELabel()

    // MARK: init
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


    // MARK: private methods
    private func initialize() {
        self.stackView.axis = .horizontal
        self.stackView.alignment = .center
        self.stackView.distribution = .fill
        self.stackView.spacing = 8

        self.authorLabel.setWhiteFontFormat(align: .left)
        self.dateLabel.setWhiteFontFormat(align: .left)
        self.amountLabel.setWhiteFontFormat(align: .right)
        self.statusLabel.setWhiteFontFormat(align: .right)

        self.authorLabel.numberOfLines = 1
        self.dateLabel.numberOfLines = 1
        self.amountLabel.numberOfLines = 1
        self.statusLabel.numberOfLines = 1

        self.dateLabel.font = GZEConstants.Font.main.increase(by: -4)
        self.statusLabel.font = GZEConstants.Font.main.increase(by: -4)

        self.dateLabel.textColor = UIColor(white: 5/6, alpha: 1)
        self.statusLabel.textColor = UIColor(white: 5/6, alpha: 1)

        self.rightView.setContentHuggingPriority(UILayoutPriority(rawValue: 300), for: .horizontal)
        self.rightView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 800), for: .horizontal)
        self.amountLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 300), for: .horizontal)
        self.statusLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 300), for: .horizontal)
        self.amountLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 800), for: .horizontal)
        self.statusLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 800), for: .horizontal)

        self.leftView.addSubview(self.authorLabel)
        self.leftView.addSubview(self.dateLabel)

        self.rightView.addSubview(self.amountLabel)
        self.rightView.addSubview(self.statusLabel)

        self.stackView.addArrangedSubview(self.leftView)
        self.stackView.addArrangedSubview(self.rightView)

        self.addSubview(self.stackView)

        // Constraints
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.authorLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.amountLabel.translatesAutoresizingMaskIntoConstraints = false
        self.statusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.leftView.translatesAutoresizingMaskIntoConstraints = false
        self.rightView.translatesAutoresizingMaskIntoConstraints = false

        self.topAnchor.constraint(equalTo: self.stackView.topAnchor, constant: -5).isActive = true
        self.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 5).isActive = true
        self.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor).isActive = true

        // Left view
        self.leftView.leadingAnchor.constraint(equalTo: self.authorLabel.leadingAnchor).isActive = true
        self.leftView.topAnchor.constraint(equalTo: self.authorLabel.topAnchor).isActive = true
        self.leftView.trailingAnchor.constraint(equalTo: self.authorLabel.trailingAnchor).isActive = true

        self.leftView.leadingAnchor.constraint(equalTo: self.dateLabel.leadingAnchor).isActive = true
        self.leftView.bottomAnchor.constraint(equalTo: self.dateLabel.bottomAnchor).isActive = true
        self.leftView.trailingAnchor.constraint(equalTo: self.dateLabel.trailingAnchor).isActive = true

        self.authorLabel.bottomAnchor.constraint(equalTo: self.dateLabel.topAnchor, constant: -2).isActive = true

        // Right view
        self.rightView.leadingAnchor.constraint(equalTo: self.amountLabel.leadingAnchor).isActive = true
        self.rightView.topAnchor.constraint(equalTo: self.amountLabel.topAnchor).isActive = true
        self.rightView.trailingAnchor.constraint(equalTo: self.amountLabel.trailingAnchor).isActive = true

        self.rightView.leadingAnchor.constraint(equalTo: self.statusLabel.leadingAnchor).isActive = true
        self.rightView.bottomAnchor.constraint(equalTo: self.statusLabel.bottomAnchor).isActive = true
        self.rightView.trailingAnchor.constraint(equalTo: self.statusLabel.trailingAnchor).isActive = true

        self.amountLabel.bottomAnchor.constraint(equalTo: self.statusLabel.topAnchor, constant: -2).isActive = true



        //self.iconView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        //self.iconView.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }

    func setCellModel(_ model: GZEBalanceCellModel) {
        self.author = model.author
        self.amount = model.amount
        self.amountColor = model.amountColor
        self.date = model.date
        self.status = model.status
    }

    func clear() {
        self.author = nil
        self.amount = nil
        self.amountColor = GZEConstants.Color.mainTextColor
        self.date = nil
        self.status = nil
    }
}
