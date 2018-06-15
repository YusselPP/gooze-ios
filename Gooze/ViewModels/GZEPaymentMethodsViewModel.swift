//
//  GZEPaymentMethodsViewModel.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/14/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

protocol GZEPaymentMethodsViewModel {

    var error: MutableProperty<String?> {get}
    var loading: MutableProperty<Bool> {get}

    var viewShownObs: Observer<Bool, NoError> {get}

    var segueAvailableMethods: Signal<GZEPaymentMethodsViewModel, NoError> {get}
    var dismiss: Signal<Void, NoError> {get}
    var addPayPal: Signal<Void, NoError> {get}

    var title: MutableProperty<String?> {get}
    var paymentslist: MutableProperty<[GZEPaymentCellModel]> {get}

    var bottomActionButtonTitle: MutableProperty<String> {get}
    var bottomActionButtonEnabled: MutableProperty<Bool> {get}
    var bottomActionButtonHidden: MutableProperty<Bool> {get}
    var bottomActionButtonAction: CocoaAction<GZEButton>?  {get}
}
