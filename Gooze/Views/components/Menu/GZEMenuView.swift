//
//  GZEMenuView.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/18/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEMenuView: UIView {

    let scrollView = UIScrollView()
    let menuList = UIStackView()
    let background = UIView()
    // let dismissView = DismissView()
    let closeBarButton = GZECloseUIBarButtonItem()
    lazy var dismissView: UIButton = {
        return self.closeBarButton.button
    }()

    var onDismiss: (() -> ())?

    init() {
        super.init(frame: CGRect.zero)
        self.initProperties()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initProperties()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initProperties()
    }

    private func initProperties() {
        self.menuList.alignment = .fill
        self.menuList.axis = .vertical
        self.menuList.distribution = .fill

        self.background.backgroundColor = .darkGray
        self.background.alpha = 0.95

        //self.dismissView.label.font = GZEConstants.Font.mainSuperBig
        //self.dismissView.label.textColor = .white
        //self.dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissViewTapped)))
        self.closeBarButton.onButtonTapped = self.dismissViewTapped

        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.addSubview(self.menuList)

        self.addSubview(self.background)
        self.addSubview(self.scrollView)
        self.addSubview(self.dismissView)

        // Constraints
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.background.translatesAutoresizingMaskIntoConstraints = false
        self.menuList.translatesAutoresizingMaskIntoConstraints = false
        self.dismissView.translatesAutoresizingMaskIntoConstraints = false

        // Superview -> Background
        self.leadingAnchor.constraint(equalTo: self.background.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.background.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: self.background.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.background.bottomAnchor).isActive = true

        // Superview -> ScrollView
        self.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: -8).isActive = true
        self.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor, constant: 8).isActive = true
        self.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: -30).isActive = true
        self.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: 10).isActive = true

        // Superview -> Dismiss view
        self.trailingAnchor.constraint(equalTo: self.dismissView.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: self.dismissView.topAnchor).isActive = true
        self.dismissView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        self.dismissView.heightAnchor.constraint(equalToConstant: 60).isActive = true

        // Superview -> MenuList
        self.widthAnchor.constraint(equalTo: self.menuList.widthAnchor, constant: 16).isActive = true

        // ScrollView -> MenuList
        self.scrollView.leadingAnchor.constraint(equalTo: self.menuList.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.menuList.trailingAnchor).isActive = true
        self.scrollView.topAnchor.constraint(equalTo: self.menuList.topAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.menuList.bottomAnchor).isActive = true


    }

    func dismissViewTapped(_ sender: UIButton) {
        self.onDismiss?()
    }
}
