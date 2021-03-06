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
import Gloss

class GZEPaymentMethodsViewModelAdded: GZEPaymentMethodsViewModel {

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
    let topMainButtonHidden = MutableProperty<Bool>(true)
    let topMainButtonAction: CocoaAction<GZEButton>? = nil

    let paymentslist = MutableProperty<[GZEPaymentCellModel]>([])

    let bottomActionButtonTitle = MutableProperty<String>("")
    let bottomActionButtonEnabled = MutableProperty<Bool>(true)
    let bottomActionButtonHidden = MutableProperty<Bool>(false)
    var bottomActionButtonAction: CocoaAction<GZEButton>?

    // END GZEPaymentMethodsViewModel protocol

    // Private properties

    let deleteTitle = "vm.paymentMethods.delete".localized()
    let deleteConfirmMessage = "vm.paymentMethods.delete.confirm.message".localized()

    lazy var deleteAction = {
        return self.createDeleteAction()
    }()

    init() {
        log.debug("\(self) init")

        self.title.value = "vm.paymentMethods.title".localized().uppercased()
        self.bottomActionButtonTitle.value = "vm.paymentMethods.add".localized().uppercased()
        self.bottomActionButtonAction = CocoaAction(self.createAddPaymentAction())

        self.viewShown.signal.observeValues {[weak self] shown in
            guard let this = self else {return}
            if shown {
                this.loading.value += 1
                PayPalService.shared.getPaymentMethods().start {

                    switch $0 {
                    case .value: break
                    default:
                        this.loading.value -= 1
                    }

                    switch $0 {
                    case .value(let methods):
                        this.paymentslist.value = methods.map{ method in
                            GZEPaymentCellModel(
                                title: method.name,
                                icon: BTUIKViewUtil.vectorArtView(for: .payPal, size: .large),
                                swipeActionEnabled: true,
                                onTap: nil,
                                onClose: {[weak self] cell in
                                    log.debug("close tapped \(String(describing: cell.model?.title))")
                                    guard let this = self else {return}
                                    GZEAlertService.shared.showConfirmDialog(
                                        title: this.deleteTitle,
                                        message: this.deleteConfirmMessage,
                                        cancelButtonTitle: "No",
                                        destructiveButtonTitle: this.deleteTitle,
                                        destructiveHandler: {[weak self] _ in
                                            self?.loading.value += 1
                                            self?.deleteAction.apply(method).start()
                                        }
                                    )
                                }
                            )
                        }
                    case .failed(let error):
                        log.error(error)
                        this.onError(error)
                    default: break
                    }
                }
            }
        }

        self.deleteAction.events.observeValues{[weak self] event in
            log.debug("Event received: \(event)")
            guard let this = self else {return}

            switch event {
            case .value: break
            default:
                this.loading.value -= 1
            }

            switch event {
            case .completed:
                // Reload payment methods
                this.viewShownObs.send(value: true)
                break
            case .failed(let error):
                this.onError(error)
            default:
                break
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

    func createDeleteAction() -> Action<GZEPayPalPaymentMethod, JSON, GZEError> {
        return Action {method in
            return PayPalService.shared.deletePayPalMethod(method)
        }
    }

    func onError(_ error: GZEError) {
        self.error.value = error.localizedDescription
    }

    deinit {
        log.debug("\(self) disposed")
    }
}
