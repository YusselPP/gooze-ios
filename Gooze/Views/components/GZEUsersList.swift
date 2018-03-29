//
//  GZEUsersList.swift
//  Gooze
//
//  Created by Yussel on 3/26/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEUsersList: UIView {

    // MARK: - public vars
    var onDismiss: (() -> ())?

    var users: [GZEUser] {
        set(users) {
            self.usersListCollectionView.users = users
            self.usersListCollectionView.reloadData()
        }
        get {
            return self.usersListCollectionView.users
        }
    }

    var onUserTap: ((UITapGestureRecognizer, GZEUserBalloon) -> ())? {
        set(onUserTap) {
            self.usersListCollectionView.onUserTap = onUserTap
        }
        get {
            return self.usersListCollectionView.onUserTap
        }
    }

    let actionButton = GZEButton()


    // MARK: - private vars
    private let usersListCollectionView = GZEUsersListCollectionView()
    private let dismissView = DismissView()

    private let usersListBackground = UIView()


    // MARK: - init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        log.debug("\(self) init")
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        log.debug("\(self) init")
        initialize()
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }


    // MARK: - Public methods
    func show() {
        UIView.animate(withDuration: 0.5) {[weak self] in
            self?.alpha = 1
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.5) {[weak self] in
            self?.alpha = 0
        }
        self.onDismiss?()
    }


    // MARK: - Private methods
    private func initialize() {
        self.alpha = 0
        
        self.usersListBackground.layer.cornerRadius = 15
        self.usersListBackground.layer.masksToBounds = true
        self.usersListBackground.backgroundColor = UIColor(white: 1/3, alpha: 0.7)
        self.actionButton.setGrayFormat()
        self.dismissView.label.font = GZEConstants.Font.mainBig
        self.dismissView.label.textColor = .white
        self.dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))


        self.addSubview(self.usersListBackground)
        self.addSubview(self.usersListCollectionView)
        self.addSubview(self.actionButton)
        self.addSubview(self.dismissView)


        // Constraints
        self.translatesAutoresizingMaskIntoConstraints = false
        self.usersListBackground.translatesAutoresizingMaskIntoConstraints = false

        // Background view
        self.topAnchor.constraint(equalTo: self.usersListBackground.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.usersListBackground.bottomAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.usersListBackground.trailingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.usersListBackground.leadingAnchor).isActive = true

        // Users list collection
        self.topAnchor.constraint(equalTo: self.usersListCollectionView.topAnchor, constant: -30).isActive = true
        self.bottomAnchor.constraint(equalTo: self.usersListCollectionView.bottomAnchor, constant: 55).isActive = true
        self.trailingAnchor.constraint(equalTo: self.usersListCollectionView.trailingAnchor, constant: 10).isActive = true
        self.leadingAnchor.constraint(equalTo: self.usersListCollectionView.leadingAnchor, constant: -10).isActive = true

        // Action button
        self.bottomAnchor.constraint(equalTo: self.actionButton.bottomAnchor, constant: 10).isActive = true
        self.centerXAnchor.constraint(equalTo: self.actionButton.centerXAnchor).isActive = true

        // Dismiss view
        self.trailingAnchor.constraint(equalTo: self.dismissView.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: self.dismissView.topAnchor).isActive = true
        self.dismissView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        self.dismissView.heightAnchor.constraint(equalToConstant: 60).isActive = true

    }


    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
