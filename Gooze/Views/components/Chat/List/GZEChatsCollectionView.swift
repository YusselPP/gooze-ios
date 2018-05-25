//
//  GZEChatsCollectionView.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/21/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import enum Result.NoError
import DeepDiff

class GZEChatsCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let cellIdentifier = "GZEChatsCollectionViewCell"

    var cells: [GZEChatCellModelDates] {
        set {
            self.setDateRequests(newValue)
        }
        get {
            return self._cells
        }
    }

    var _cells = [GZEChatCellModelDates]()

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
        self.register(GZEChatsCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
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

        guard let chatCell = cell as? GZEChatsCollectionViewCell else {
            log.error("Unable to cast cell to \(GZEChatsCollectionViewCell.self)")
            return cell
        }

        guard row >= 0 && row < self._cells.count else {
            log.error("Index path out of messages array bounds")
            chatCell.clear()
            return chatCell
        }

        // Cell borders
        chatCell.borders.forEach{$0.removeFromSuperlayer()}
        chatCell.borders.append(chatCell.addBorder(at: .bottom, color: .white, width: 1))
        if row == 0 {
            chatCell.borders.append(chatCell.addBorder(at: .top, color: .white, width: 1))
        }

        chatCell.model = self._cells[row]

        return chatCell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.size.width, height: calcCellHeight(indexPath: indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // MARK: - Helpers
    private func setDateRequests(_ cells: [GZEChatCellModelDates]) {
        let changes = diff(old: self._cells, new: cells)
        self._cells = cells
        log.debug("Changes: \(changes)")
        self.reload(changes: changes, section: 0) { _ in

        }
    }

    private func calcCellHeight(indexPath: IndexPath) -> CGFloat {
        return 80
    }


    // MARK: - Deinitializer
    deinit {
        log.debug("\(self) disposed")
    }
}

extension Reactive where Base: GZEChatsCollectionView {
    var cells: BindingTarget<[GZEChatCellModelDates]> {
        return makeBindingTarget {
            $0.cells = $1
        }
    }
}
