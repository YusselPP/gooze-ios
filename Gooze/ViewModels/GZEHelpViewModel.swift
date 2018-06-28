//
//  GZEHelpViewModel.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/28/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

protocol GZEHelpViewModel {
    var error: MutableProperty<String?> {get}
    var loading: MutableProperty<Bool> {get}
    var dismiss: Signal<Void, NoError> {get}
    var viewShownObs: Observer<Bool, NoError> {get}
    var title: MutableProperty<String?> {get}

    var bottomButtonTitle: MutableProperty<String> {get}
    var bottomButtonEnabled: MutableProperty<Bool> {get}
    var bottomButtonAction: CocoaAction<GZEButton>?  {get}

    var subjectPlaceholder: MutableProperty<String> {get}
    var subjectText: MutableProperty<String?> {get}

    var bodyPlaceholder: MutableProperty<String> {get}
    var bodyText: MutableProperty<String?> {get}
}
