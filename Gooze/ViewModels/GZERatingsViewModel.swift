//
//  GZERatingsViewModel.swift
//  Gooze
//
//  Created by Yussel on 3/7/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol GZERatingsViewModel {

    var mode: MutableProperty<GZEProfileMode> { get }
    var error: MutableProperty<String?> { get }

    var contactButtonTitle: String { get }
    var acceptRequestButtonTitle: String { get }
    
    var username: MutableProperty<String?> { get }

    var profilePic: MutableProperty<URLRequest?> { get }

    var phrase: MutableProperty<String?> { get }

    var imagesRatingDesc: MutableProperty<String?> { get }
    var complianceRatingDesc: MutableProperty<String?> { get }
    var dateQualityRatingDesc: MutableProperty<String?> { get }
    var dateRatingDesc: MutableProperty<String?> { get }
    var goozeRatingDesc: MutableProperty<String?> { get }
    
    var imagesRating: MutableProperty<Float?> { get }
    var complianceRating: MutableProperty<Float?> { get }
    var dateQualityRating: MutableProperty<Float?> { get }
    var dateRating: MutableProperty<Float?> { get }
    var goozeRating: MutableProperty<Float?> { get }

    var overallRating: MutableProperty<Float?> { get }

    func contact();

    func acceptRequest();
}
