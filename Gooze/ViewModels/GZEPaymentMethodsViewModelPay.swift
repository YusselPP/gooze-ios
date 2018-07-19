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

    // END GZEPaymentMethodsViewModel protocol

    // Private properties

    init(amount: Double, dateRequest: MutableProperty<GZEDateRequest>, senderId: String, username: String, chat: GZEChat, mode: GZEChatViewMode) {
        log.debug("\(self) init")

        self.title.value = "vm.paymentMethods.title.selectMethod".localized().uppercased()
        // TODO: config currency and gooze tax 
        self.topMainButtonTitle.value = (GZENumberHelper.shared.currencyFormatter.string(from: NSNumber(value: amount)) ?? "$0") + " MXN"
        self.bottomActionButtonTitle.value = "vm.paymentMethods.add".localized().uppercased()
        self.bottomActionButtonAction = CocoaAction(self.createAddPaymentAction())

        self.viewShown.signal.observeValues {[weak self] shown in
            guard let this = self else {return}
            if shown {
                this.loading.value = true
                PayPalService.shared.getPaymentMethods().start {
                    this.loading.value = false
                    switch $0 {
                    case .value(let methods):
                        this.paymentslist.value = methods.map{ method in
                            GZEPaymentCellModel(
                                title: method.name,
                                icon: BTUIKViewUtil.vectorArtView(for: .payPal, size: .large),
                                onTap: {[weak self] _ in
                                    guard let this = self else {return}
                                    this.loading.value = true
                                    PayPalService.shared.charge(amount: amount, paymentMethodToken: method.token, dateRequest: dateRequest.value)
                                        .start{[weak self] in
                                            guard let this = self else {return}
                                            this.loading.value = false
                                            switch $0 {
                                            case .failed(let error):
                                                this.onError(error)
                                            case .value(let response):
                                                guard let success = response["success"] as? Bool else {
                                                    log.error("Invalid response from server")
                                                    return
                                                }

                                                if success {
                                                    GZEDatesService.shared.createCharge(
                                                        requestId: dateRequest.value.id,
                                                        senderId: senderId,
                                                        username: username,
                                                        chat: chat,
                                                        mode: mode
                                                    ).start{[weak self] event in
                                                            log.debug("event received: \(event)")
                                                            guard let this = self else { log.error("self was disposed"); return }

                                                            switch event {
                                                            case .value(let newdateRequest):
                                                                dateRequest.value = newdateRequest
                                                                this.dismissObs.send(value: ())
                                                            case .failed(let error):
                                                                this.error.value = error.localizedDescription
                                                            default: break
                                                            }
                                                    }
                                                } else {
                                                    log.error("error: \(response)")
                                                    if let message = response["message"] as? String {
                                                        this.error.value = message
                                                    }
                                                }
                                            default: break
                                            }
                                        }
                            })
                        }
                    case .failed(let error):
                        log.error(error)
                        this.onError(error)
                    default: break
                    }
                }
            }
        }
    }

    // Private Methods
    func createAddPaymentAction() -> Action<Void, Void, GZEError> {
        return Action.init(enabledIf: self.bottomActionButtonEnabled) {[weak self] in
            guard let this = self else {return SignalProducer(error: .repository(error: .UnexpectedError))}

            this.segueAvailableMethodsObs.send(value: GZEPaymentMethodsViewModelAvailable())

            return SignalProducer.empty
        }
    }

    func onError(_ error: GZEError) {
        self.error.value = error.localizedDescription
    }

    deinit {
        log.debug("\(self) disposed")
    }
}
