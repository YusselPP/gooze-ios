//
//  GZELibraryCollectionViewCell.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/18/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import Photos

class GZELibraryCollectionViewCell: UICollectionViewCell {
    let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = #imageLiteral(resourceName: "image-placeholder")
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = #imageLiteral(resourceName: "image-placeholder")
    }

    func configureWithModel(_ model: PHAsset) {

        if tag != 0 {
            PHImageManager.default().cancelImageRequest(PHImageRequestID(tag))
        }

        tag = Int(PHImageManager.default().requestImage(for: model, targetSize: contentView.bounds.size, contentMode: .aspectFill, options: nil) { image, info in
            self.imageView.image = image
        })
    }
}
