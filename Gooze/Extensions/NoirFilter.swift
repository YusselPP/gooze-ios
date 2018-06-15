//
//  NoirFilter.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/13/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import AlamofireImage

public struct NoirFilter: ImageFilter, CoreImageFilter {
    /// The filter name.
    public let filterName = "CIPhotoEffectNoir"

    /// The image filter parameters passed to CoreImage.
    public let parameters: [String: Any] = [:]

    /// Initializes the `BlurFilter` instance with the given blur radius.
    ///
    /// - parameter blurRadius: The blur radius.
    ///
    /// - returns: The new `BlurFilter` instance.
    public init() {
    }
}
