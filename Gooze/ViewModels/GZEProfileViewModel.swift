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

    var mode: MutableProperty<GZEProfileMode> { get }
    var error: MutableProperty<String?> { get }

    var contactButtonTitle: String { get }
    var acceptRequestButtonTitle: String { get }
    
    var chatViewModel: GZEChatViewModel { get }

    func contact()

    func acceptRequest()
    
    func observeMessages()
    func stopObservingMessages()
}

enum GZEProfileMode {
    case request
    case contact
}
