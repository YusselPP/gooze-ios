//
//  GZEUsersListCollectionView.swift
//  Gooze
//
//  Created by Yussel on 3/8/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEUsersListCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var users = [GZEUserConvertible]()
    var onUserTap: ((UITapGestureRecognizer, GZEUserBalloon) -> ())?
    
    private var padding: CGFloat {
        switch GZEConstants.horizontalSize {
        case .compact:
            return 8
        default:
            return 15
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    init() {
        super.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        initialize()
    }

    func initialize() {
        log.debug("\(self) init")
        self.dataSource = self
        self.delegate = self
        self.backgroundColor = nil
        self.translatesAutoresizingMaskIntoConstraints = false

        self.register(GZEUserCollectionViewCell.self, forCellWithReuseIdentifier: "GZEUserCollectionViewCell")
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        log.debug("bounds: \(self.bounds)")

        let maxSize: CGFloat = 200
        let minViewSize = min(bounds.width, bounds.height)
        
        var size = minViewSize/2 - 2 * self.padding

        if size > maxSize {
            size = minViewSize/3 - 2 * self.padding
        }

        return CGSize(width: size, height: size);
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.padding
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(self.padding, self.padding, self.padding, self.padding)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = self.dequeueReusableCell(withReuseIdentifier: "GZEUserCollectionViewCell", for: indexPath)

        log.debug("cell: \(cell)")

        guard let userCell = cell as? GZEUserCollectionViewCell else {
            log.debug("unable to cast cell to user collection view cell")
            return cell
        }


        userCell.user = users[indexPath.row]
        userCell.onTap = onUserTap
        userCell.userBalloon.setVisible(true)

        return userCell
    }

}

class GZEUserCollectionViewCell: UICollectionViewCell {

    var user: GZEUserConvertible? {
        didSet {
            setUser(self.user)
        }
    }
    var onTap: ((UITapGestureRecognizer, GZEUserBalloon) -> ())? {
        didSet {
            self.userBalloon.onTap = self.onTap
        }
    }

    let userBalloon: GZEUserBalloon

    required init?(coder aDecoder: NSCoder) {
        userBalloon = GZEUserBalloon()
        super.init(coder: aDecoder)
        log.debug("\(self) init")
        initProperties()
    }

    override init(frame: CGRect) {
        userBalloon = GZEUserBalloon()
        super.init(frame: frame)
        log.debug("\(self) init")
        initProperties()
    }

    init() {
        userBalloon = GZEUserBalloon()
        super.init(frame: CGRect.zero)
        log.debug("\(self) init")
        initProperties()
    }


    private func initProperties() {
        self.contentMode = .center

        userBalloon.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(userBalloon)

        self.topAnchor.constraint(equalTo: userBalloon.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: userBalloon.bottomAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: userBalloon.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: userBalloon.rightAnchor).isActive = true
    }

    private func setUser(_ user: GZEUserConvertible?) {
        userBalloon.setUser(user)
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
