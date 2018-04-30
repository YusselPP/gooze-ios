//
//  GZEMapViewModelDate.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/20/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZEMapViewModelDate: NSObject, GZEMapViewModel {

    // MARK - GZEMapViewModel protocol

    let topSliderHidden = MutableProperty<Bool>(true)

    let topLabelText = MutableProperty<String?>("")
    let topLabelHidden = MutableProperty<Bool>(true)

    var bottomButtonAction: CocoaAction<GZEButton>?
    let bottomButtonTitle = MutableProperty<String>("")
    let bottomButtonActionEnabled = MutableProperty<Bool>(false)
    let (dismissSignal, dismissObserver) = Signal<Bool, NoError>.pipe()

    let isMapUserInteractionEnabled = MutableProperty<Bool>(false)

    // End GZEMapViewModel protocol

    // MARK - init
    override init() {
        super.init()
        log.debug("\(self) init")

        self.bottomButtonAction = CocoaAction(self.createBottomButtonAction())
    }

    func createBottomButtonAction() -> Action<Void, Bool, GZEError> {
        return Action.init(enabledIf: self.bottomButtonActionEnabled) {[weak self] in
            guard let this = self else { log.error("self was disposed"); return SignalProducer(error: .repository(error: .UnexpectedError))}

            this.dismissObserver.send(value: true)

            return SignalProducer.empty
        }
    }

    // MARK - deinit
    deinit {
        log.debug("\(self) disposed")
    }
}
