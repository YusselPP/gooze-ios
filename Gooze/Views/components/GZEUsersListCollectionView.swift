//
//  GZEUsersListCollectionView.swift
//  Gooze
//
//  Created by Yussel on 3/8/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEUsersListCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var users = [GZEUser]()
    var onUserTap: ((UITapGestureRecognizer, GZEUserBalloon) -> ())?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dataSource = self
        self.delegate = self
        self.backgroundColor = nil
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        log.debug("bounds: \(self.bounds)")

        let minSize = min(bounds.width, bounds.height)
        let size = max(minSize/3 - 2 * 15, 100)

        return CGSize(width: size, height: size);
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

        return userCell
    }

}

class GZEUserCollectionViewCell: UICollectionViewCell {

    var user: GZEUser? {
        didSet {
            setUser(self.user)
        }
    }
    var onTap: ((UITapGestureRecognizer, GZEUserBalloon) -> ())? {
        didSet {
            self.userBalloon?.onTap = self.onTap
        }
    }

    let userBalloon: GZEUserBalloon?

    init() {
        userBalloon = GZEUserBalloon()
        super.init(frame: CGRect.zero)
        log.debug("\(self) init")
        initProperties()
    }

    required init?(coder aDecoder: NSCoder) {
        userBalloon = GZEUserBalloon(coder: aDecoder)
        super.init(coder: aDecoder)
        log.debug("\(self) init")
        initProperties()
    }

    private func initProperties() {
        guard let userBalloon = self.userBalloon else { return }

        userBalloon.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(userBalloon)

        self.topAnchor.constraint(equalTo: userBalloon.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: userBalloon.bottomAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: userBalloon.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: userBalloon.rightAnchor).isActive = true
    }

    private func setUser(_ user: GZEUser?) {
        guard let user = user else { return }
        guard let userBalloon = self.userBalloon else { return }

        userBalloon.setUser(user)
    }
}
