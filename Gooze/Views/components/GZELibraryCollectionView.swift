//
//  GZELibraryCollectionView.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/18/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import enum Result.NoError
import DeepDiff
import ALCameraViewController
import Photos

class GZELibraryCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private let cellIdentifier = "GZELibraryCollectionViewCell"

    public var onSelectionComplete: PhotoLibraryViewSelectionComplete?

    private var padding: CGFloat {
        switch GZEConstants.horizontalSize {
        case .compact:
            return 8
        default:
            return 15
        }
    }

    var assets: PHFetchResult<PHAsset>? = nil

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
        self.register(GZELibraryCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        self.backgroundColor = .clear
        self.delegate = self
        self.dataSource = self
    }

    func fetchImages() {
        _ = ImageFetcher()
            .onFailure(onFailure)
            .onSuccess(onSuccess)
            .fetch()
    }

    private func onSuccess(_ photos: PHFetchResult<PHAsset>) {
        self.assets = photos
        self.reloadData()
    }

    private func onFailure(_ error: NSError) {
        // TODO: Show permissions error
        log.error(error)
    }

    internal func itemAtIndexPath(_ indexPath: IndexPath) -> PHAsset? {
        return assets?[(indexPath as NSIndexPath).row]
    }

    // MARK: - UITableViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets?.count ?? 0
    }

    @objc(collectionView:willDisplayCell:forItemAtIndexPath:) public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell is GZELibraryCollectionViewCell {
            if let model = itemAtIndexPath(indexPath) {
                (cell as! GZELibraryCollectionViewCell).configureWithModel(model)
            }
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectionComplete?(itemAtIndexPath(indexPath))
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let columns: CGFloat = 4
        let size = (bounds.width - (padding * 2))/columns

        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(self.padding, self.padding, self.padding, self.padding)
    }

    // MARK: - Deinitializer
    deinit {
        log.debug("\(self) disposed")
    }
}

