//
//  GZECarouselUIView.swift
//  Gooze
//
//  Created by Yussel Paredes on 11/2/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import iCarousel

class GZECarouselUIView: iCarousel, iCarouselDelegate {

    var selectedImage = MutableProperty<UIImage?>(nil)

    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        // dataSource = self
        type = .linear
        contentMode = .scaleToFill
        bounces = false
        log.debug("\(self) init")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        // dataSource = self
        type = .linear
        contentMode = .scaleToFill
        bounces = false
        log.debug("\(self) init")
    }

    func appendPhoto(_ image: UIImage?) {
        if let vm = dataSource as? GZESignUpViewModel {
            vm.photos.append(MutableProperty(image))
            insertItem(at: vm.photos.count - 1, animated: true)
        }
    }

    func removePhoto(_ image: UIImage?, at index: Int) {
        if let vm = dataSource as? GZESignUpViewModel {
            vm.photos.remove(at: index)
            removeItem(at: index, animated: true)
        }
    }

    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        if let imageView = carousel.currentItemView as? UIImageView {
            selectedImage.value = imageView.image
        }
        log.debug("current index: \(carousel.currentItemIndex)")
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
