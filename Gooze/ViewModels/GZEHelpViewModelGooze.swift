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

    let messageSend = "vm.help.messageSend".localized()
    let userRepository: GZEUserRepositoryProtocol = GZEUserApiRepository()
    lazy var sendAction: CocoaAction<GZEButton> = {
        return CocoaAction<GZEButton>(self.send){_ in self.loading.value = true}
    }()

    lazy var send = {
        Action<Void, Void, GZEError>(enabledIf: self.bottomButtonEnabled){[weak self]_ in
            guard let this = self else {return SignalProducer.empty}
            guard let subject = this.subjectText.value, let text = this.bodyText.value, !subject.isEmpty, !text.isEmpty else {
                return SignalProducer(error: .validation(error: .required(fieldName: this.bodyPlaceholder.value)))
            }
            return this.userRepository.sendEmail(subject: subject, text: text)
        }
    }()

    init() {
        log.debug("\(self) init")
        self.bottomButtonAction = self.sendAction

        self.send.events.observeValues({[weak self] event in
            log.debug("event: \(event)")
            guard let this = self else {return}
            this.loading.value = false
            switch event {
            case .completed:
                this.error.value = this.messageSend
                this.dismissObs.send(value: ())
            case .failed(let error):
                this.error.value = error.localizedDescription
            default: break
            }
        })
    }

    deinit {
        log.debug("\(self) disposed")
    }
}
