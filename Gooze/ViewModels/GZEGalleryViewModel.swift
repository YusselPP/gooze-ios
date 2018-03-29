//
//  GZEGalleryViewModel.swift
//  Gooze
//
//  Created by Yussel on 3/6/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol GZEGalleryViewModel {

    var mode: MutableProperty<GZEProfileMode> { get }
    var error: MutableProperty<String?> { get }

    var contactButtonTitle: String { get }
    var acceptRequestButtonTitle: String { get }
    
    var username: MutableProperty<String?> { get }

    var thumbnails: [MutableProperty<URLRequest?>] { get }

    func contact();

    func acceptRequest();
}
