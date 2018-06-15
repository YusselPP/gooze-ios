//
//  GZEPaymentCollectionViewCell.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/14/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEPaymentCollectionViewCell: UICollectionViewCell {
    var model: GZEPaymentCellModel? {
        didSet {
            if let model = self.model {
                self.setCellModel(model)
            } else {
                self.clear()
            }
        }
    }

    var title: String? {
        set{
            self.titleLabel.text = newValue
        }
        get {
            return self.titleLabel.text
        }
    }

    var icon: UIView? {
        willSet {
            self.icon?.removeFromSuperview()
        }
        didSet{
            if let icon = self.icon {
                self.iconView.addSubview(icon)
                icon.translatesAutoresizingMaskIntoConstraints = false
                //self.iconView.topAnchor.constraint(equalTo: icon.topAnchor).isActive = true
                //self.iconView.leadingAnchor.constraint(equalTo: icon.leadingAnchor).isActive = true
                //self.iconView.bottomAnchor.constraint(equalTo: icon.bottomAnchor).isActive = true
                //self.iconView.trailingAnchor.constraint(equalTo: icon.trailingAnchor).isActive = true
                self.iconView.centerXAnchor.constraint(equalTo: icon.centerXAnchor).isActive = true
                self.iconView.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
                icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
                icon.heightAnchor.constraint(equalToConstant: 20).isActive = true
            }
        }
    }

    override var isSelected: Bool {
        didSet {
            log.debug("isSelected: \(self.isSelected)")
        }
    }

    var onTap: HandlerBlock<GZEPaymentCollectionViewCell>?

    let stackView = UIStackView()
    let iconView = UIView()
    let titleLabel = GZELabel()

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
        self.stackView.spacing = 15

        self.titleLabel.setWhiteFontFormat(align: .natural)
        self.iconView.layer.cornerRadius = 5
        self.iconView.layer.masksToBounds = true
        self.iconView.backgroundColor = .lightGray

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))

        self.stackView.addArrangedSubview(self.iconView)
        self.stackView.addArrangedSubview(self.titleLabel)

        self.addSubview(self.stackView)

        // Constraints
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.iconView.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false

        self.topAnchor.constraint(equalTo: self.stackView.topAnchor, constant: -5).isActive = true
        self.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 5).isActive = true
        self.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor).isActive = true

        self.iconView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.iconView.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }

    func setCellModel(_ model: GZEPaymentCellModel) {
        self.title = model.title
        self.icon = model.icon
        self.onTap = model.onTap
    }

    func clear() {
        self.title = nil
        self.onTap = nil
    }

    func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.onTap?(self)
    }
}
