//
//  GZEChatsViewModel.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/23/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

protocol GZEChatsViewModel {

    var title: MutableProperty<String?> {get}
    var chatsList: MutableProperty<[GZEChatCellModelDates]> {get}

    var error: MutableProperty<String?> {get}
    var loading: MutableProperty<Bool> {get}
    
    var dismiss: Signal<Void, NoError> {get}
    var segueToChat: Signal<GZEChatViewModelDates, NoError> {get}

    func viewWillAppear()
    func viewDidDisappear()
}
