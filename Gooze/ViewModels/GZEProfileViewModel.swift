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

    var mode: GZEProfileMode { get set}
    var dateRequest: GZEDateRequest? { get set }
    var acceptRequestAction: Action<Void, GZEDateRequest, GZEError>! {get set}
    var error: MutableProperty<String?> { get }

    var actionButtonTitle: MutableProperty<String> { get }
    
    var chatViewModel: GZEChatViewModel { get }
    
    weak var controller: UIViewController? { get set }

    func startObservers()
    func stopObservers()
}

enum GZEProfileMode {
    case request
    case contact
}
