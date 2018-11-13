//
//  GZEBalanceViewModelPay.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/29/18.
//  Copyright © 2018 Gooze. All rights reserved.
//
import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZEBalanceViewModelPay: GZEBalanceViewModel {

    // GZEBalanceViewModel protocol
    let error = MutableProperty<String?>(nil)
    let loading = MutableProperty<Bool>(false)
    let (viewShown, viewShownObs) = Signal<Bool, NoError>.pipe()
    let (dismiss, dismissObs) = Signal<Void, NoError>.pipe()
    let title = MutableProperty<String?>("vm.balance.pay.title".localized())
    let navigationRightButton = MutableProperty<UIBarButtonItem?>(nil)

    let list = MutableProperty<[GZEBalanceCellModel]>([])
    let rightLabelText = MutableProperty<String?>(nil)
    let rightLabelTextColor = MutableProperty<UIColor>(GZEConstants.Color.mainTextColor)
    let bottomStackHidden = MutableProperty<Bool>(false)

    let dataAtBottom = true

    let bottomActionButtonTitle = MutableProperty<String>("")
    let bottomActionButtonHidden = MutableProperty<Bool>(true)
    let bottomActionButtonCocoaAction: CocoaAction<GZEButton>? = nil

    let segueToHistoryDetail = Signal<GZEHistoryDetailViewModel,NoError>.empty
    // END GZEBalanceViewModel protocol

    // Private properties
    let mode: GZEChatViewMode
    let transactionsRepository: GZEUserTransactionsRepositoryProtocol = GZEUserTransactionsApiRepositroy()
    let transactions = MutableProperty<[GZETransaction]>([])
    lazy var findTransactions: () -> SignalProducer<[GZETransaction], GZEError> = {
        if self.mode == .gooze {
            return self.transactionsRepository.findGooze
        } else {
            return self.transactionsRepository.findClient
        }
    }()

    let total = MutableProperty<Decimal>(Decimal(0))

    init(mode: GZEChatViewMode) {
        self.mode = mode

        log.debug("\(self) init")

        if mode == .client {
            self.bottomStackHidden.value = true
        } else {
            self.total <~ self.transactions.map{$0.reduce(Decimal(0), {
                let trans = $1

                if trans.goozeStatus == .paid {
                    return $0 + (trans.paidAmount ?? Decimal(0))
                } else {
                    return $0 + trans.netAmount
                }
            })}

            self.rightLabelText <~ self.total.map{
                $0.toCurrencyString() ?? "$0"
            }
        }

        self.viewShown.signal.observeValues {[weak self] shown in
            guard let this = self else {return}
            if shown {
                this.updateBalance()
            }
        }

        self.list <~ (
            self.transactions
                .map{
                    $0.map{trans in

                        var amount: String?
                        if mode == .client {
                            amount = trans.amount.toCurrencyString()
                        } else {
                            if trans.goozeStatus == .paid {
                                amount = trans.paidAmount?.toCurrencyString()
                            } else {
                                amount = trans.netAmount.toCurrencyString()
                            }
                        }

                        return GZEBalanceCellModel(
                            author: mode == .client ? trans.to : trans.from,
                            date: GZEDateHelper.displayDateTimeFormatter.string(from: trans.createdAt),
                            amount: amount ?? "$0",
                            amountColor: GZEConstants.Color.mainTextColor,
                            status: mode == .client ? "" : trans.goozeStatus.localizedDescription
                        )
                    }
                }
        )
    }

    // Private Methods
    func updateBalance() {
        self.loading.value = true
        self.findTransactions().start {[weak self] in
            guard let this = self else {return}
            this.loading.value = false
            switch $0 {
            case .value(let transactions):
                this.transactions.value = transactions
            case .failed(let error):
                log.error(error)
                this.onError(error)
            default: break
            }
        }
    }

    func onError(_ error: GZEError) {
        self.error.value = error.localizedDescription
    }

    deinit {
        log.debug("\(self) disposed")
    }
}
