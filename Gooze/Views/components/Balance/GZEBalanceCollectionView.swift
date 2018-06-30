//
//  GZEBalanceCollectionView.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/28/18.
//  Copyright © 2018 Gooze. All rights reserved.
//
import UIKit
import ReactiveSwift
import enum Result.NoError
import DeepDiff

class GZEBalanceCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let cellIdentifier = "GZEBalanceCollectionCell"

    var cells: [GZEBalanceCellModel] {
        set {
            self.setCells(newValue)
        }
        get {
            return self._cells
        }
    }

    var _cells = [GZEBalanceCellModel]()

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
        self.register(GZEBalanceCollectionCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.delegate = self
    }

    func initDatasource(){
        if self.dataSource == nil {
            self.dataSource = self
        }
    }

    // MARK: - UITableViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self._cells.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        let row = indexPath.row

        guard let balanceCell = cell as? GZEBalanceCollectionCell else {
            log.error("Unable to cast cell to \(GZEBalanceCollectionCell.self)")
            return cell
        }

        guard row >= 0 && row < self._cells.count else {
            log.error("Index path out of messages array bounds")
            balanceCell.clear()
            return balanceCell
        }

        balanceCell.model = self._cells[row]

        return balanceCell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.size.width, height: calcCellHeight(indexPath: indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let itemsHeight = CGFloat(50 * numberOfItems(inSection: section))
        return UIEdgeInsets(top: max(self.frame.size.height - itemsHeight, 0), left: 0, bottom: 0, right: 0)
    }

    // MARK: - Helpers
    private func setCells(_ cells: [GZEBalanceCellModel]) {
        let changes = diff(old: self._cells, new: cells)
        self._cells = cells
        log.debug("Changes: \(changes)")

        guard self.dataSource != nil else {return}

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
extension Reactive where Base: GZEBalanceCollectionView {
    var cells: BindingTarget<[GZEBalanceCellModel]> {
        return makeBindingTarget {
            $0.cells = $1
        }
    }
}
