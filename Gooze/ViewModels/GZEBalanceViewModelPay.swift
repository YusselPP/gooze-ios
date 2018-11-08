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
    let title = MutableProperty<String?>(nil)
    let navigationRightButton = MutableProperty<UIBarButtonItem?>(nil)

    let list = MutableProperty<[GZEBalanceCellModel]>([])
    let rightLabelText = MutableProperty<String?>(nil)
    let rightLabelTextColor = MutableProperty<UIColor>(.green)
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

    init(mode: GZEChatViewMode) {
        self.mode = mode

        log.debug("\(self) init")

        self.title.value = "vm.balance.pay.title".localized()

        self.viewShown.signal.observeValues {[weak self] shown in
            guard let this = self else {return}
            if shown {
                this.updateBalance()
            }
        }

        let authUser = GZEAuthService.shared.authUser

        self.rightLabelText <~ self.transactions
            .map{$0.reduce(Decimal(0), {
                let trans = $1
                //if trans.from == authUser?.username {
                 //   return $0 - trans.amount
                //} else {
                //    return $0 + trans.amount
                //}

                if trans.goozeStatus == .paid {
                    return $0 + (trans.paidAmount ?? Decimal(0))
                } else {
                    return $0 + trans.netAmount
                }
            })}
            .map{GZENumberHelper.shared.currencyFormatter.string(from: NSDecimalNumber(decimal: $0)) ?? "$0"}

        self.rightLabelTextColor <~ self.transactions
            .map{$0.reduce(Decimal(0) , {
                let trans = $1
                //if trans.from == authUser?.username {
                //   return $0 - trans.amount
                //} else {
                //    return $0 + trans.amount
                //}

                if trans.goozeStatus == .paid {
                    return $0 + (trans.paidAmount ?? Decimal(0))
                } else {
                    return $0 + trans.netAmount
                }
            })}
            .map{$0 < 0 ? GZEConstants.Color.textInputPlacehoderOnEdit : .white}

        self.list <~ (
            self.transactions
                .map{
                    $0.map{trans in

                        var amount: String
                        if trans.goozeStatus == .paid {
                            amount = trans.paidAmount?.toCurrencyString() ?? "$0"
                        } else {
                            amount = trans.netAmount.toCurrencyString() ?? "$0"
                        }

                        return GZEBalanceCellModel(
                            author: trans.from == authUser?.username ? trans.to : trans.from,
                            date: GZEDateHelper.displayDateTimeFormatter.string(from: trans.createdAt),
                            amount: amount,
                            amountColor: .white,
                            status: trans.goozeStatus.localizedDescription
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
