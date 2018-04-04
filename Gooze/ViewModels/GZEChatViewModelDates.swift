//
//  GZEDatesChatViewModel.swift
//  Gooze
//
//  Created by Yussel on 3/31/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZEChatViewModelDates: GZEChatViewModel {

    // MARK: - GZEChatViewModel
    let mode: GZEChatViewMode
    let error = MutableProperty<String?>(nil)

    let username = MutableProperty<String?>(nil)
    let messages = MutableProperty<[GZEChatMessage]>([])
    let backgroundImage = MutableProperty<URLRequest?>(nil)

    let topButtonTitle = MutableProperty<String?>(nil)
    let topButtonEnabled = MutableProperty<Bool>(true)
    var topButtonAction: CocoaAction<UIButton>!

    let inputMessage = MutableProperty<String?>(nil)
    let sendButtonImage = MutableProperty<UIImage?>(nil)
    let sendButtonEnabled = MutableProperty<Bool>(true)
    var sendButtonAction: CocoaAction<UIButton>!

    let recipient: GZEChatUser

    // MARK: - init
    init(recipient: GZEChatUser) {
        var mode: GZEChatViewMode
        if let isActivated = GZEAuthService.shared.authUser?.isActivated, isActivated {
            mode = .gooze
        } else {
            mode = .client
        }

        self.mode = mode
        self.recipient = recipient

        self.topButtonAction = CocoaAction(self.createTopButtonAction())
        self.sendButtonAction = CocoaAction(self.createSendAction())

        GZEChatService.shared.activeRecipientId = recipient.id
        messages.bindingTarget <~ GZEChatService.shared.receivedMessages.map {
            $0[recipient.id] ?? []
        }
    }

    // MARK: - Actions
    private func createTopButtonAction() -> Action<Void, Bool, GZEError> {
        return Action(enabledIf: topButtonEnabled) {[weak self] () -> SignalProducer<Bool, GZEError> in
            guard let this = self else {
                log.error("self disposed before executing action")
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }

            return SignalProducer.empty
        }
    }

    private func createSendAction() -> Action<Void, Void, GZEError> {
        return Action(enabledIf: sendButtonEnabled) {[weak self] () -> SignalProducer<Void, GZEError> in
            guard let this = self else {
                log.error("self disposed before executing action")
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }

            guard let messageText = this.inputMessage.value else {
                return SignalProducer(error: .validation(error: .required(fieldName: "messageText")))
            }
            
            let messageTextTrim = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !messageTextTrim.isEmpty else {
                return SignalProducer(error: .validation(error: .required(fieldName: "messageText")))
            }
            
            guard let sender = GZEAuthService.shared.authUser else {
                log.error("sender is nil")
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }


            let message = GZEChatMessage(
                text: messageTextTrim,
                sender: sender.toChatUser(),
                recipient: this.recipient
            )

            GZEChatService.shared.send(message: message)
            
            this.inputMessage.value = ""

            return SignalProducer.empty
        }
    }
}
