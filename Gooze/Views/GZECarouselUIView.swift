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

class GZECarouselUIView: iCarousel, iCarouselDelegate, iCarouselDataSource {

    var images: [UIImage?] =  Array(repeating: #imageLiteral(resourceName: "default-profile-pic"), count: 5)
    var selectedImage = MutableProperty<UIImage?>(nil)

    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        dataSource = self
        type = .linear
        contentMode = .scaleToFill
        bounces = false
        log.debug("\(self) init")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        dataSource = self
        type = .linear
        contentMode = .scaleToFill
        bounces = false
        log.debug("\(self) init")
    }

    func setImage(_ image: UIImage?, at index: Int) {

        // if index >
        // images[index] = image
        
    }

    func appendImage(_ image: UIImage?) {
        images.append(image)
    }

    func numberOfItems(in carousel: iCarousel) -> Int {
        return images.count
    }

    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {

        var itemView: UIImageView

        //reuse view if available, otherwise create a new view
        if let view = view as? UIImageView {
            itemView = view
        } else {
            //don't do anything specific to the index within
            //this `if ... else` statement because the view will be
            //recycled and used with other index values later
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            itemView.image = images[index]
            itemView.contentMode = .scaleToFill
        }

        log.debug("item showed \(index)")
        return itemView
    }

    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        if let imageView = carousel.currentItemView as? UIImageView {
            selectedImage.value = imageView.image
        }
    }

//    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
//        if (option == .spacing) {
//            return value * 0.5
//        }
//        return value
//    }

//    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
//        log.debug("selected \(index)")
//        selectedImage.value = images[index]
//    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
