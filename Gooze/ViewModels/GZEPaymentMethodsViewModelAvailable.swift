//
//  GZEPaymentMethodsViewModelAvailable.swift
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

class GZEPaymentMethodsViewModelAvailable: GZEPaymentMethodsViewModel {

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
    let topMainButtonAction: CocoaAction<GZEButton>? = nil
    
    let paymentslist = MutableProperty<[GZEPaymentCellModel]>([])

    let bottomActionButtonTitle = MutableProperty<String>("")
    let bottomActionButtonEnabled = MutableProperty<Bool>(true)
    let bottomActionButtonHidden = MutableProperty<Bool>(true)
    var bottomActionButtonAction: CocoaAction<GZEButton>?

    // END GZEPaymentMethodsViewModel protocol

    var image: UIView?

    // Private properties

    init() {
        log.debug("\(self) init")

        self.title.value = "vm.paymentMethods.addMethod".localized().uppercased()
        self.paymentslist.value.append(
            GZEPaymentCellModel(
                title: BTUIKViewUtil.name(forPaymentMethodType: .payPal),
                icon: BTUIKViewUtil.vectorArtView(for: .payPal, size: .large),
                onTap: {[weak self] in
                    self?.handleAddPayPalMethod($0)
                }
            )
        )
    }

    // Private Methods
    func createAddPaymentAction() -> Action<Void, Void, GZEError> {
        return Action(enabledIf: self.bottomActionButtonEnabled) {
            return SignalProducer.empty
        }
    }

    func handleAddPayPalMethod(_ cell: GZEPaymentCollectionViewCell) {
        self.addPayPalObs.send(value: ())
    }

    deinit {
        log.debug("\(self) disposed")
    }
}
