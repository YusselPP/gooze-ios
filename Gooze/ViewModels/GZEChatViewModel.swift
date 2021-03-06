//
//  GZEChatViewModel.swift
//  Gooze
//
//  Created by Yussel on 3/31/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

protocol GZEChatViewModel {

    var mode: GZEChatViewMode { get }
    var error: MutableProperty<String?> { get }

    var username: MutableProperty<String?> { get }
    var messages: MutableProperty<[GZEChatMessage]> { get }
    var backgroundImage: MutableProperty<URLRequest?> { get }

    var topButtonTitle: MutableProperty<String> { get }
    var topButtonEnabled: MutableProperty<Bool> { get }
    var topButtonIsHidden: MutableProperty<Bool> { get }
    var topButtonAction: CocoaAction<GZEButton>? { get }
    
    var topAccessoryButtonEnabled: MutableProperty<Bool> { get }
    var topAccessoryButtonIsHidden: MutableProperty<Bool> { get }
    var topAccessoryButtonAction: CocoaAction<UIButton>? { get }
    
    var topTextInput: MutableProperty<String?> { get }
    var topTextInputIsHidden: MutableProperty<Bool> { get }
    var topTextInputIsEditing: MutableProperty<Bool> { get }
    var topTextInputEndEditingSignal: Signal<Void, NoError> { get }

    var inputMessage: MutableProperty<String?> { get }
    var sendButtonImage: MutableProperty<UIImage?> { get }
    var sendButtonAction: MutableProperty<CocoaAction<UIButton>?> { get }

    var paymentViewModel: GZEPaymentMethodsViewModel? { get }
    var mapViewModel: GZEMapViewModel { get }

    var showPaymentViewSignal: Signal<Bool, NoError> { get }
    var showMapViewSignal: Signal<Void, NoError> { get }
    
    var chat: GZEChat { get }
    
    func startObservers()
    func stopObservers()
    
    var retrieveHistoryProducer: SignalProducer<Void, GZEError>? { get }
    func retrieveHistory()
}

enum GZEChatViewMode: String {
    case gooze
    case client
}
