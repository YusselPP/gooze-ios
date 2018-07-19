//
//  GZEPaymentMethodsViewModelAdded.swift
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

class GZEPaymentMethodsViewModelAdded: GZEPaymentMethodsViewModel {

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
    let topMainButtonHidden = MutableProperty<Bool>(true)

    let paymentslist = MutableProperty<[GZEPaymentCellModel]>([])

    let bottomActionButtonTitle = MutableProperty<String>("")
    let bottomActionButtonEnabled = MutableProperty<Bool>(true)
    let bottomActionButtonHidden = MutableProperty<Bool>(false)
    var bottomActionButtonAction: CocoaAction<GZEButton>?

    // END GZEPaymentMethodsViewModel protocol

    // Private properties

    init() {
        log.debug("\(self) init")

        self.title.value = "vm.paymentMethods.title".localized().uppercased()
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
                        this.paymentslist.value = methods.map{
                            GZEPaymentCellModel(
                                title: $0.name,
                                icon: BTUIKViewUtil.vectorArtView(for: .payPal, size: .large),
                                onTap: nil)
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
