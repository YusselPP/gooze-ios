//
//  GZEPaymentMethodsViewModelPay.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/14/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError
import BraintreeDropIn
import Gloss

class GZEPaymentMethodsViewModelPay: GZEPaymentMethodsViewModel {

    // GZEPaymentMethodsViewModel protocol
    let error = MutableProperty<String?>(nil)
    let loading = MutableProperty<Int>(0)

    weak var controller: UIViewController?

    let (viewShown, viewShownObs) = Signal<Bool, NoError>.pipe()

    let (dismiss, dismissObs) = Signal<Void, NoError>.pipe()
    let (segueAvailableMethods, segueAvailableMethodsObs) = Signal<GZEPaymentMethodsViewModel, NoError>.pipe()
    let (addPayPal, addPayPalObs) = Signal<Void, NoError>.pipe()

    let title = MutableProperty<String?>(nil)
    let navigationRightButton = MutableProperty<UIBarButtonItem?>(nil)

    let topMainButtonTitle = MutableProperty<String>("")
    let topMainButtonHidden = MutableProperty<Bool>(false)
    var topMainButtonAction: CocoaAction<GZEButton>? = nil

    let paymentslist = MutableProperty<[GZEPaymentCellModel]>([])

    let bottomActionButtonTitle = MutableProperty<String>("")
    let bottomActionButtonEnabled = MutableProperty<Bool>(true)
    let bottomActionButtonHidden = MutableProperty<Bool>(false)
    var bottomActionButtonAction: CocoaAction<GZEButton>?

    let selectPaymentMethodText = "vm.paymentMethods.title.selectMethod".localized()
    let addPaymentMethodTitle = "vm.paymentMethods.add".localized()
    let payText = "vm.paymentMethods.pay".localized()
    let feeDescription = "vm.paymentMethods.feeDescription".localized()

    // END GZEPaymentMethodsViewModel protocol

    // Private properties
    let dateRequest: MutableProperty<GZEDateRequest>
    let senderId: String
    let username: String
    let chat: GZEChat
    let mode: GZEChatViewMode
    let requestedAmount: Decimal

    let amount = MutableProperty<Decimal>(0)
    let clientTax = MutableProperty<Decimal>(0)
    let clientTaxAmount = MutableProperty<Decimal>(0)
    let goozeTax = MutableProperty<Decimal>(0)
    let goozeTaxAmount = MutableProperty<Decimal>(0)
    let methodProperty = MutableProperty<GZEPaymentMethod?>(nil)
    let methods = MutableProperty<[GZEPaymentMethod]>([])

    lazy var payAction = {
        return self.createPayAction()
    }()

    lazy var noncePayAction = {
        return self.createNoncePayAction()
    }()

    init(amount: Decimal, dateRequest: MutableProperty<GZEDateRequest>, senderId: String, username: String, chat: GZEChat, mode: GZEChatViewMode) {
        self.dateRequest = dateRequest
        self.senderId = senderId
        self.username = username
        self.chat = chat
        self.mode = mode
        self.requestedAmount = amount

        log.debug("\(self) init")

        self.title.value = selectPaymentMethodText.uppercased()
        self.bottomActionButtonTitle.value = payText.uppercased()
        self.bottomActionButtonAction = CocoaAction(self.noncePayAction)
        self.topMainButtonAction = CocoaAction<GZEButton>(Action<(), Any, NoError>{_ in SignalProducer.empty}, {
            [weak self] _ in
            self?.showPayDetails()
            return
        }) as CocoaAction<GZEButton>

        self.goozeTaxAmount <~ self.goozeTax.map{amount * $0}.map{$0.rounded(2)}
        self.clientTaxAmount <~ self.clientTax.map{amount * $0}.map{$0.rounded(2)}
        self.amount <~ self.clientTaxAmount.map{amount + $0}.map{$0.rounded(2)}
        self.topMainButtonTitle <~ self.amount.map{
            (GZENumberHelper.shared.currencyFormatter.string(from: NSDecimalNumber(decimal: $0)) ?? "$0") + " MXN"
        }

        self.methodProperty <~ self.methods.map{$0.first}

        self.paymentslist.value = [
            GZEPaymentCellModel(
                isSelection: true,
                title: "PayPal",
                icon: BTUIKViewUtil.vectorArtView(for: .payPal, size: .large)
            )
        ]

//        self.paymentslist <~ self.methods.combineLatest(with: methodProperty).map{[weak self] in
//            let (methods, selectedMethod) = $0
//            return methods.map{[weak self] method in
//                GZEPaymentCellModel(
//                    isSelection: method == selectedMethod,
//                    title: method.name,
//                    icon: BTUIKViewUtil.vectorArtView(for: .payPal, size: .large),
//                    onTap: {[weak self] _ in
//                        self?.methodProperty.value = method
//                    }
//                )
//            }
//        }.map{[weak self] (cells: [GZEPaymentCellModel]) in
//            var cellModels = cells
//            // Append add payment row
//            cellModels.append(GZEPaymentCellModel(
//                type: .add,
//                title: self?.addPaymentMethodTitle,
//                onTap: {
//                    [weak self] _ in
//                    self?.segueAvailableMethodsObs.send(value: GZEPaymentMethodsViewModelAvailable())
//                }
//            ))
//
//            return cellModels
//        }

        self.viewShown.signal.observeValues {[weak self] shown in
            guard let this = self else {return}
            if shown {
                this.loading.value += 1

                GZEAppConfig.loadRemote().start
                    {[weak self] in
                        guard let this = self else {return}

                        switch $0 {
                        case .value: break
                        default:
                            this.loading.value -= 1
                        }

                        switch $0 {
                        case .value(let config):
                            if
                                let clientTaxString: String = "clientTax" <~~ config,
                                let clientTax = Decimal(string: clientTaxString)
                            {
                                this.clientTax.value = clientTax
                            }

                            if
                                let goozeTaxString: String = "goozeTax" <~~ config,
                                let goozeTax = Decimal(string: goozeTaxString)
                            {
                                this.goozeTax.value = goozeTax
                            }
                        case .failed(let error):
                            log.error(error)
                            this.onError(error)
                        default: break
                        }
                }
            }
        }
//        self.viewShown.signal.observeValues {[weak self] shown in
//            guard let this = self else {return}
//            if shown {
//                this.loading.value += 1
//
//                PayPalService.shared.getPaymentMethods()
//                    .combineLatest(with: GZEAppConfig.loadRemote()).start
//                    {[weak self] in
//                        guard let this = self else {return}
//
//                        switch $0 {
//                        case .value: break
//                        default:
//                            this.loading.value -= 1
//                        }

//                        switch $0 {
//                        case .value(let (methods, config)):
//                            this.methods.value = methods
//
//                            if
//                                let clientTaxString: String = "clientTax" <~~ config,
//                                let clientTax = Decimal(string: clientTaxString)
//                            {
//                                this.clientTax.value = clientTax
//                            }
//
//                            if
//                                let goozeTaxString: String = "goozeTax" <~~ config,
//                                let goozeTax = Decimal(string: goozeTaxString)
//                            {
//                                this.goozeTax.value = goozeTax
//                            }
//                        case .failed(let error):
//                            log.error(error)
//                            this.onError(error)
//                        default: break
//                        }
//                    }
//            }
//        }

        self.payAction.events.observeValues{[weak self] event in
            log.debug("Event received: \(event)")

            guard let this = self else {return}

            switch event {
            case .value: break
            default:
                this.loading.value -= 1
            }

            switch event {
            case .value(let value):
                let (newdateRequest, newSender) = value
                this.dateRequest.value = newdateRequest
                GZEAuthService.shared.authUser = newSender
                this.dismissObs.send(value: ())
            case .failed(let err):
                this.onError(err)
            default:
                break
            }
        }

        self.noncePayAction.events.observeValues{[weak self] event in
            log.debug("Event received: \(event)")

            guard let this = self else {return}

            switch event {
            case .value: break
            default:
                this.loading.value -= 1
            }

            switch event {
            case .value(let value):
                let (newdateRequest, newSender) = value
                this.dateRequest.value = newdateRequest
                GZEAuthService.shared.authUser = newSender
                this.dismissObs.send(value: ())
            case .failed(let err):
                this.onError(err)
            default:
                break
            }
        }

        observeDateRequestUpdates()
    }

    // Private Methods
    func showPayDetails() {
        GZEAlertService.shared.showConfirmDialog(
            message: (
                "\(self.dateRequest.value.recipient.username): \(self.requestedAmount.toCurrencyString() ?? "$0")\n" +
                "\(self.feeDescription): \(self.clientTaxAmount.value.toCurrencyString() ?? "$0")"
            ),
            cancelButtonTitle: "Ok"
        )
    }

    func createPayAction() -> Action<Void, (GZEDateRequest, GZEUser), GZEError> {
        return Action.init(enabledIf: self.bottomActionButtonEnabled) {[weak self] in
            guard let this = self else {return SignalProducer(error: .repository(error: .UnexpectedError))}

            guard let method = this.methodProperty.value else {
                return SignalProducer(error: .message(text: this.selectPaymentMethodText, args: []))
            }

            this.loading.value += 1

            return this.createCharge(method: method)
        }
    }

    func createNoncePayAction() -> Action<Void, (GZEDateRequest, GZEUser), GZEError> {
        return Action(enabledIf: self.bottomActionButtonEnabled) {[weak self] in

            guard let this = self, let controller = this.controller else {
                return SignalProducer(error: .repository(error: .UnexpectedError))
            }

            this.loading.value += 1

            return (
                PayPalService.shared.oneTimePaymentNonce(amount: this.amount.value, presenter: controller)
                    .flatMap(.latest) {[weak self] tokenizedPayPalAccount -> SignalProducer<(GZEDateRequest, GZEUser), GZEError> in
                        guard let this = self else {
                            return SignalProducer(error: .repository(error: .UnexpectedError))
                        }

                        return this.createCharge(nonce: tokenizedPayPalAccount.nonce)
                    }
            )
        }
    }

    

    func createCharge(method: GZEPaymentMethod)
        -> SignalProducer<(GZEDateRequest, GZEUser), GZEError> {

            return (
                GZEDatesService.shared.createCharge(
                    dateRequest: self.dateRequest.value,
                    amount: self.amount.value,
                    clientTaxAmount: self.clientTaxAmount.value,
                    goozeTaxAmount: self.goozeTaxAmount.value,
                    paymentMethodToken: method.token,
                    senderId: self.senderId,
                    username: self.username,
                    chat: self.chat,
                    mode: self.mode
                )
            )
    }

    func createCharge(nonce: String)
        -> SignalProducer<(GZEDateRequest, GZEUser), GZEError> {

            return (
                GZEDatesService.shared.createCharge(
                    dateRequest: self.dateRequest.value,
                    amount: self.amount.value,
                    clientTaxAmount: self.clientTaxAmount.value,
                    goozeTaxAmount: self.goozeTaxAmount.value,
                    paymentMethodNonce: nonce,
                    senderId: self.senderId,
                    username: self.username,
                    chat: self.chat,
                    mode: self.mode
                )
            )
    }

    func onError(_ error: GZEError) {
        self.error.value = error.localizedDescription
    }

    func observeDateRequestUpdates() {
        log.debug("start observing date request updates")

        Signal.merge([
            GZEDatesService.shared.lastSentRequest.signal,
            GZEDatesService.shared.lastReceivedRequest.signal
        ])
        .skipNil()
        .filter{[weak self] in
            guard let this = self else {return false}
            return $0.id == this.dateRequest.value.id
        }
        //.take(until: viewShown.filter{!$0}.map{_ in ()})
        .take(during: amount.lifetime)
        .observe{[weak self] in
            log.debug("event: \($0)")
            guard let this = self else {return}
            switch $0 {
            case .value(let dateRequest):
                this.dateRequest.value = dateRequest
            default: break
            }
        }
        /*.observeValues {[weak self] dateRequest in
            guard let this = self else {return}
            this.dateRequest.value = dateRequest
        }*/

    }

    deinit {
        log.debug("\(self) disposed")
    }
}
