//
//  GZEGalleryViewModel.swift
//  Gooze
//
//  Created by Yussel on 3/6/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol GZEGalleryViewModel: GZEProfileViewModel {

    var username: MutableProperty<String?> { get }

    var thumbnails: [MutableProperty<URLRequest?>] { get }
    
}
