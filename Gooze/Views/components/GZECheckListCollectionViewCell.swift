//
//  GZECheckListCollectionViewCell.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/20/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZECheckListCollectionViewCell: UICollectionViewCell {
    var model: GZECheckListItem? {
        didSet {
            if let model = self.model {
                self.setCellModel(model)
            } else {
                self.clear()
            }
        }
    }

    var label: String? {
        set{
            self.titleLabel.text = newValue
        }
        get {
            return self.titleLabel.text
        }
    }

    var index: Int?

    var checked: Bool = false {
        didSet {
            log.debug("checked: \(self.checked)")
            guard uiSwitch.isOn != self.checked else {
                return
            }

            //self.uiSwitch.setOn(self.checked, animated: true)
            self.uiSwitch.isOn = self.checked
        }
    }

    var onChange: HandlerBlock<Bool>?

    let stackView = UIStackView()
    let uiSwitch = UISwitch()
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

        self.uiSwitch.tintColor = GZEConstants.Color.mainGreen
        self.uiSwitch.onTintColor = GZEConstants.Color.mainGreen
        self.uiSwitch.reactive.isOnValues.observeValues{[weak self] in
            self?.onChange?($0)
        }

        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.uiSwitch)

        self.addSubview(self.stackView)

        // Constraints
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false

        self.topAnchor.constraint(equalTo: self.stackView.topAnchor, constant: -5).isActive = true
        self.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 5).isActive = true
        self.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor).isActive = true

        self.uiSwitch.widthAnchor.constraint(equalToConstant: 60).isActive = true
        //self.uiSwitch.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }

    func setCellModel(_ model: GZECheckListItem) {
        self.index = model.index
        self.label = model.label
        self.checked = model.checked
        self.onChange = model.onChange
    }

    func clear() {
        self.index = nil
        self.label = nil
        self.checked = false
        self.onChange = nil
    }
}
