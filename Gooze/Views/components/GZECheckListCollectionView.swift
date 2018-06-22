//
//  GZECheckListCollectionView.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/20/18.
//  Copyright © 2018 Gooze. All rights reserved.
//
import UIKit
import ReactiveSwift
import enum Result.NoError
import DeepDiff

class GZECheckListCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let cellIdentifier = "GZECheckListCollectionViewCell"

    var cells: [GZECheckListItem] {
        set {
            self.setItems(newValue)
        }
        get {
            return self._cells
        }
    }

    var _cells = [GZECheckListItem]()

    // MARK: - init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init(frame: CGRect, collectionViewLayout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        initialize()
    }

    init() {
        super.init(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        initialize()
    }

    func initialize() {
        log.debug("initializing \(self)")
        self.backgroundColor = .clear
        self.register(GZECheckListCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.delegate = self
        self.dataSource = self
    }

    // MARK: - UITableViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self._cells.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        let row = indexPath.row

        guard let checkListCell = cell as? GZECheckListCollectionViewCell else {
            log.error("Unable to cast cell to \(GZECheckListCollectionViewCell.self)")
            return cell
        }

        guard row >= 0 && row < self._cells.count else {
            log.error("Index path out of messages array bounds")
            checkListCell.clear()
            return checkListCell
        }

        checkListCell.model = self._cells[row]

        return checkListCell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.size.width, height: calcCellHeight(indexPath: indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // MARK: - Helpers
    private func setItems(_ cells: [GZECheckListItem]) {
        let changes = diff(old: self._cells, new: cells)
        self._cells = cells
        log.debug("Changes: \(changes)")
        self.reload(changes: changes, section: 0) { _ in

        }
    }

    private func calcCellHeight(indexPath: IndexPath) -> CGFloat {
        return 50
    }


    // MARK: - Deinitializer
    deinit {
        log.debug("\(self) disposed")
    }
}
extension Reactive where Base: GZECheckListCollectionView {
    var cells: BindingTarget<[GZECheckListItem]?> {
        return makeBindingTarget {
            if let cells = $1 {
                $0.cells = cells
            }
        }
    }
}
