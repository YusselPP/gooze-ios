//
//  GZEProfileViewModel.swift
//  Gooze
//
//  Created by Yussel on 2/22/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift

protocol GZEProfileViewModel {

    // basic data
    var username: MutableProperty<String?> { get }

    // additional data
    var phrase: MutableProperty<String?> { get }
    var gender: MutableProperty<String?> { get }
    var age: MutableProperty<String?> { get }
    var height: MutableProperty<String?> { get }
    var weight: MutableProperty<String?> { get }
    var origin: MutableProperty<String?> { get }
    var languages: MutableProperty<String?> { get }
    var interestedIn: MutableProperty<String?> { get }
    // TODO: Implement ocupation in user model
    var ocupation: MutableProperty<String?> { get }

    var profilePic: MutableProperty<URLRequest?> { get }

    func contact(controller: UIViewController);
}
