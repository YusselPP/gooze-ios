//
//  GZEMapViewModel.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/20/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

protocol GZEMapViewModel {
    var bottomButtonAction: CocoaAction<GZEButton>? { get }
    var bottomButtonActionEnabled: MutableProperty<Bool> { get }
    var dismissSignal: Signal<Bool, NoError> { get }
}
