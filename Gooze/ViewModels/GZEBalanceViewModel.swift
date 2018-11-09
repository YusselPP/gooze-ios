//
//  GZEBalanceViewModel.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/28/18.
//  Copyright © 2018 Gooze. All rights reserved.
//
import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

protocol GZEBalanceViewModel {

    var error: MutableProperty<String?> {get}
    var loading: MutableProperty<Bool> {get}
    var dismiss: Signal<Void, NoError> {get}
    var viewShownObs: Observer<Bool, NoError> {get}
    var title: MutableProperty<String?> {get}
    var navigationRightButton: MutableProperty<UIBarButtonItem?> {get}

    var list: MutableProperty<[GZEBalanceCellModel]> {get}
    var rightLabelText: MutableProperty<String?> {get}
    var rightLabelTextColor: MutableProperty<UIColor> {get}

    var bottomStackHidden: MutableProperty<Bool> {get}

    var dataAtBottom: Bool {get}
}
