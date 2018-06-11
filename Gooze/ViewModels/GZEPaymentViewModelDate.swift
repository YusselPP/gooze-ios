//
//  GZEPaymentViewModelDate.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/20/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZEPaymentViewModelDate: NSObject, GZEPaymentViewModel {

    // MARK - GZEPaymentViewModel protocol
    let errorMessage = MutableProperty<String?>(nil)
    
    var bottomButtonCocoaAction: CocoaAction<GZEButton>?
    let bottomButtonActionEnabled = MutableProperty<Bool>(true)
    let (dismissSignal, dismissObserver) = Signal<Void, NoError>.pipe()

    // End GZEPaymentViewModel protocol

    let dateRequest: MutableProperty<GZEDateRequest>
    var bottomButtonAction: Action<Void, GZEDateRequest, GZEError>!


    let senderId: String, username: String, chat: GZEChat, mode: GZEChatViewMode
    
    // MARK - init
    init(dateRequest: MutableProperty<GZEDateRequest>, senderId: String, username: String, chat: GZEChat, mode: GZEChatViewMode) {
        self.dateRequest = dateRequest
        self.senderId = senderId
        self.username = username
        self.chat = chat
        self.mode = mode
        super.init()
        log.debug("\(self) init")

        self.bottomButtonAction = self.createBottomButtonAction()
        self.bottomButtonCocoaAction = CocoaAction(self.bottomButtonAction)

        self.bottomButtonAction.events.observeValues{[weak self] event in
            log.debug("Bottom action button event received: \(event)")
            guard let this = self else { log.error("self was disposed"); return }


            switch event {
            case .value(let dateRequest):
                this.dateRequest.value = dateRequest
            case .completed:
                this.dismissObserver.send(value: ())
            case .failed(let error):
                this.errorMessage.value = error.localizedDescription
            default: break
            }
        }
    }

    func createBottomButtonAction() -> Action<Void, GZEDateRequest, GZEError> {
        return Action.init(enabledIf: self.bottomButtonActionEnabled) {[weak self] in
            guard let this = self else { log.error("self was disposed"); return SignalProducer(error: .repository(error: .UnexpectedError))}
            
            return GZEDatesService.shared.createCharge(
                requestId: this.dateRequest.value.id,
                senderId: this.senderId,
                username: this.username,
                chat: this.chat,
                mode: this.mode
            )
        }
    }
    
    // MARK - deinit
    deinit {
        log.debug("\(self) disposed")
    }
}
