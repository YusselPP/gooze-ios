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

class GZEPaymentMethodsViewModelPay: GZEPaymentMethodsViewModel {

    // GZEPaymentMethodsViewModel protocol
    let error = MutableProperty<String?>(nil)
    let loading = MutableProperty<Bool>(false)

    let (viewShown, viewShownObs) = Signal<Bool, NoError>.pipe()

    let (dismiss, dismissObs) = Signal<Void, NoError>.pipe()
    let (segueAvailableMethods, segueAvailableMethodsObs) = Signal<GZEPaymentMethodsViewModel, NoError>.pipe()
    let (addPayPal, addPayPalObs) = Signal<Void, NoError>.pipe()

    let title = MutableProperty<String?>(nil)
    let navigationRightButton = MutableProperty<UIBarButtonItem?>(nil)

    let topMainButtonTitle = MutableProperty<String>("")
    let topMainButtonHidden = MutableProperty<Bool>(false)

    let paymentslist = MutableProperty<[GZEPaymentCellModel]>([])

    let bottomActionButtonTitle = MutableProperty<String>("")
    let bottomActionButtonEnabled = MutableProperty<Bool>(true)
    let bottomActionButtonHidden = MutableProperty<Bool>(false)
    var bottomActionButtonAction: CocoaAction<GZEButton>?

    let selectPaymentMethodText = "vm.paymentMethods.title.selectMethod".localized()
    let addPaymentMethodTitle = "vm.paymentMethods.add".localized()
    let payText = "vm.paymentMethods.pay".localized()

    // END GZEPaymentMethodsViewModel protocol

    // Private properties
    let amount: Double
    let dateRequest: MutableProperty<GZEDateRequest>
    let senderId: String
    let username: String
    let chat: GZEChat
    let mode: GZEChatViewMode

    let methodProperty = MutableProperty<GZEPaymentMethod?>(nil)
    let methods = MutableProperty<[GZEPaymentMethod]>([])

    lazy var payAction = {
        return self.createPayAction()
    }()

    init(amount: Double, dateRequest: MutableProperty<GZEDateRequest>, senderId: String, username: String, chat: GZEChat, mode: GZEChatViewMode) {
        self.amount = amount
        self.dateRequest = dateRequest
        self.senderId = senderId
        self.username = username
        self.chat = chat
        self.mode = mode

        log.debug("\(self) init")

        self.title.value = selectPaymentMethodText.uppercased()
        // TODO: config currency and gooze tax 
        self.topMainButtonTitle.value = (GZENumberHelper.shared.currencyFormatter.string(from: NSNumber(value: amount)) ?? "$0") + " MXN"
        self.bottomActionButtonTitle.value = payText.uppercased()
        self.bottomActionButtonAction = CocoaAction(self.payAction)

        self.methodProperty <~ self.methods.map{$0.first}

        self.paymentslist <~ self.methods.combineLatest(with: methodProperty).map{
            let (methods, selectedMethod) = $0
            return methods.map{ method in
                GZEPaymentCellModel(
                    isSelection: method == selectedMethod,
                    title: method.name,
                    icon: BTUIKViewUtil.vectorArtView(for: .payPal, size: .large),
                    onTap: {[weak self] _ in
                        self?.methodProperty.value = method
                    }
                )
            }
        }.map{[weak self] (cells: [GZEPaymentCellModel]) in
            var cellModels = cells
            // Append add payment row
            cellModels.append(GZEPaymentCellModel(
                type: .add,
                title: self?.addPaymentMethodTitle,
                onTap: {
                    [weak self] _ in
                    self?.segueAvailableMethodsObs.send(value: GZEPaymentMethodsViewModelAvailable())
                }
            ))

            return cellModels
        }

        self.viewShown.signal.observeValues {[weak self] shown in
            guard let this = self else {return}
            if shown {
                this.loading.value = true
                PayPalService.shared.getPaymentMethods().start {
                    this.loading.value = false
                    switch $0 {
                    case .value(let methods):
                        this.methods.value = methods
                    case .failed(let error):
                        log.error(error)
                        this.onError(error)
                    default: break
                    }
                }
            }
        }

        self.payAction.events.observeValues{[weak self] event in
            log.debug("Event received: \(event)")

            guard let this = self else {return}

            this.loading.value = false

            switch event {
            case .value(let newdateRequest):
                this.dateRequest.value = newdateRequest
                this.dismissObs.send(value: ())
            case .failed(let err):
                this.onError(err)
            default:
                break
            }
        }
    }

    // Private Methods
    func createPayAction() -> Action<Void, GZEDateRequest, GZEError> {
        return Action.init(enabledIf: self.bottomActionButtonEnabled) {[weak self] in
            guard let this = self else {return SignalProducer(error: .repository(error: .UnexpectedError))}

            guard let method = this.methodProperty.value else {
                return SignalProducer(error: .message(text: this.selectPaymentMethodText))
            }

            return this.createCharge(method: method)
        }
    }

    func createCharge(method: GZEPaymentMethod)
        -> SignalProducer<GZEDateRequest, GZEError> {

        self.loading.value = true
        return (
            PayPalService.shared
                // TODO: Create a service in the server that has this two actions(paypal charge and create date) in order to avoid network errors in date creation
                .charge(amount: self.amount, paymentMethodToken: method.token, dateRequest: self.dateRequest.value)
                .flatMap(.latest){[weak self] response -> SignalProducer<GZEDateRequest, GZEError>  in
                    guard let this = self else {return SignalProducer.empty}

                    guard let success = response["success"] as? Bool else {
                        log.error("Invalid response from server")
                        return SignalProducer(error: .repository(error: .UnexpectedError))
                    }

                    guard success else {
                        log.error("Server response: \(response)")
                        if let message = response["message"] as? String {
                            this.error.value = message
                            return SignalProducer.empty
                        } else {
                            return SignalProducer(error: .repository(error: .UnexpectedError))
                        }
                    }

                    return (
                        GZEDatesService.shared.createCharge(
                            requestId: this.dateRequest.value.id,
                            senderId: this.senderId,
                            username: this.username,
                            chat: this.chat,
                            mode: this.mode
                        )
                    )
                }
        )
    }

    func onError(_ error: GZEError) {
        self.error.value = error.localizedDescription
    }

    deinit {
        log.debug("\(self) disposed")
    }
}
