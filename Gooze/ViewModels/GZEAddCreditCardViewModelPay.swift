//
//  GZEAddCreditCardViewModelPay.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/28/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZEAddCreditCardViewModelPay: GZEAddCreditCardViewModel {

    // MARK: - GZEAddCreditCardViewModel protocol
    let name = MutableProperty<String?>(nil)
    let cardNumber = MutableProperty<String?>(nil)
    let expMonth = MutableProperty<String?>(nil)
    let expYear = MutableProperty<String?>(nil)
    let cvc = MutableProperty<String?>(nil)

    var actionButton: CocoaAction<GZEButton>?
    let actionButtonTitle = MutableProperty<String>("")
    let actionButtonEnabled = MutableProperty<Bool>(true)

    weak var controller: UIViewController? {
        didSet {
            self.conekta.delegate = self.controller
            self.conekta.collectDevice()
        }
    }

    let error = MutableProperty<String?>(nil)
    let loading = MutableProperty<Bool>(false)

    let (dismiss, dismissObs) = Signal<Void, NoError>.pipe()
    //var segueToChat = Signal<GZEChatViewModelDates, NoError> {get}

    func viewWillAppear() {

    }

    func viewDidDisappear() {

    }
    // END GZEAddCreditCardViewModel protocol

    let addCardTitle = "vm.add.credit.card.text".localized()
    let conekta = Conekta()
    let paymentRepository: GZEPaymentRepository = GZEConektaApiRepository()
    lazy var payAction = {
        return self.createPayAction()
    }()

    // MARK: - init
    init() {
        log.debug("\(self) init")
        self.conekta.publicKey = GZEAppConfig.conektaPublicKey

        self.actionButtonTitle.value = self.addCardTitle
        self.actionButton = CocoaAction(self.payAction){[weak self] _ in
            self?.loading.value = false
        }

        self.payAction.events.observeValues{[weak self] event in
            log.debug("event received: \(event)")
            guard let this = self else {return}

            this.loading.value = false
            switch event {
            case .value(let token):
                this.error.value = "Token created"
                break
            case .failed(let error):
                this.onError(error)
            default: break
            }
        }
    }



    func createPayAction() -> Action<Void, String, GZEError> {
        return Action(enabledIf: self.actionButtonEnabled) {[weak self] in
            guard let this = self else {return SignalProducer.empty}

            guard
                let cardNumber = this.cardNumber.value,
                let name = this.name.value,
                let cvc = this.cvc.value,
                let expMonth = this.expMonth.value,
                let expYear = this.expYear.value
            else {
                return SignalProducer(error: .payment(error: .missingRequiredParams))
            }

            let card: Card = this.conekta.card()
            card.setNumber(
                cardNumber,
                name: name,
                cvc: cvc,
                expMonth: expMonth,
                expYear: expYear
            )
            let token: Token = this.conekta.token()
            token.card = card

            return this.paymentRepository.createToken(token)
        }
    }

    func onError(_ error: Error) {
        self.error.value = error.localizedDescription
    }

    // MARK: - deinit
    deinit {
        log.debug("\(self) disposed")
    }
}
