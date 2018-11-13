//
//  GZEHistoryDetailViewModel.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 11/10/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

protocol GZEHistoryDetailViewModel {

    var loading: MutableProperty<Bool> { get }
    var error: MutableProperty<String?> { get }

    var bottomActionButtonIsHidden: MutableProperty<Bool> { get }
    var bottomActionButtonTitle: MutableProperty<String> { get }
    var bottomActionButtonAction: CocoaAction<GZEButton>? { get }

    var username: MutableProperty<String?> { get }
    var status: MutableProperty<String?> { get }
    var date: MutableProperty<String?> { get }
    var amount: MutableProperty<String?> { get }
    var address: MutableProperty<String?> { get }


    var didLoadObs: Observer<Void, NoError> {get}
    var dismissSignal: Signal<Void, NoError> { get }
    var segueToHelp: Signal<GZEHelpViewModel, NoError> { get }
}
