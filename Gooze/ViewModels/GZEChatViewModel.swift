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

protocol GZEChatViewModel {

    var mode: GZEChatViewMode { get }
    var error: MutableProperty<String?> { get }

    var username: MutableProperty<String?> { get }
    var messages: MutableProperty<[GZEChatMessage]> { get }
    var backgroundImage: MutableProperty<URLRequest?> { get }

    var topButtonTitle: MutableProperty<String?> { get }
    var topButtonAction: CocoaAction<UIButton>! { get }

    var inputMessage: MutableProperty<String?> { get }
    var sendButtonImage: MutableProperty<UIImage?> { get }
    var sendButtonAction: CocoaAction<UIButton>! { get }
    
}

enum GZEChatViewMode {
    case gooze
    case client
}
