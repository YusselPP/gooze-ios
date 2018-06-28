//
//  GZEHelpViewModelGooze.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/28/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZEHelpViewModelGooze: GZEHelpViewModel {

    // MARK: - GZEHelpViewModel protocol
    let error = MutableProperty<String?>(nil)
    let loading = MutableProperty<Bool>(false)
    let (dismiss, dismissObs) = Signal<Void, NoError>.pipe()
    let (viewShown, viewShownObs) = Signal<Bool, NoError>.pipe()
    let title = MutableProperty<String?>("vm.help.title".localized().uppercased())

    let bottomButtonTitle = MutableProperty<String>("vm.help.send".localized().uppercased())
    let bottomButtonEnabled = MutableProperty<Bool>(true)
    var bottomButtonAction: CocoaAction<GZEButton>?

    let subjectPlaceholder = MutableProperty<String>("vm.help.subject".localized())
    let subjectText = MutableProperty<String?>(nil)

    let bodyPlaceholder = MutableProperty<String>("vm.help.body".localized())
    let bodyText = MutableProperty<String?>(nil)
    // END: - GZEHelpViewModel protocol

    lazy var sendAction: CocoaAction<GZEButton> = {
        return CocoaAction<GZEButton>(
            Action<Void, Void, GZEError>(enabledIf: self.bottomButtonEnabled){
                SignalProducer.empty
            }
        )
    }()

    init() {
        log.debug("\(self) init")
        self.bottomButtonAction = self.sendAction
    }

    deinit {
        log.debug("\(self) disposed")
    }
}
