//
//  GZEProfileViewModel.swift
//  Gooze
//
//  Created by Yussel on 2/22/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

protocol GZEProfileViewModel {

    var mode: GZEProfileMode { get set }
    var dateRequest: MutableProperty<GZEDateRequest?> { get }

    var bottomButtonAction: CocoaAction<GZEButton>? { get }

    var loading: MutableProperty<Bool> { get }
    var error: MutableProperty<String?> { get }

    var actionButtonTitle: MutableProperty<String> { get }

    var controller: UIViewController? { get set }

    func startObservers()
    func stopObservers()
}

enum GZEProfileMode {
    case request
    case contact
}
