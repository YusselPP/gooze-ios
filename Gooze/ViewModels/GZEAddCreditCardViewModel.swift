//
//  GZEAddCreditCardViewModel.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/28/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

protocol GZEAddCreditCardViewModel {

    var name: MutableProperty<String?> {get}
    var cardNumber: MutableProperty<String?> {get}
    var expMonth: MutableProperty<String?> {get}
    var expYear: MutableProperty<String?> {get}
    var cvc: MutableProperty<String?> {get}

    var actionButton: CocoaAction<GZEButton>? {get}
    var actionButtonTitle: MutableProperty<String> {get}
    var actionButtonEnabled: MutableProperty<Bool> {get}

    var controller: UIViewController? {get set}

    var error: MutableProperty<String?> {get}
    var loading: MutableProperty<Bool> {get}

    var dismiss: Signal<Void, NoError> {get}
    //var segueToChat: Signal<GZEChatViewModelDates, NoError> {get}

    func viewWillAppear()
    func viewDidDisappear()
}
