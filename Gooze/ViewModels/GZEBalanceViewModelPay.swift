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
    let transactionsRepository: GZEUserTransactionsRepositoryProtocol = GZEUserTransactionsApiRepositroy()
    let transactions = MutableProperty<[GZETransaction]>([])

    init() {
        log.debug("\(self) init")

        self.title.value = "vm.balance.pay.title".localized()

        self.viewShown.signal.observeValues {[weak self] shown in
            guard let this = self else {return}
            if shown {
                this.updateBalance()
            }
        }

        self.rightLabelText <~ self.transactions
            .map{$0.map{$0.amount}}
            .map{$0.reduce(0, {$0 + $1})}
            .map{GZENumberHelper.shared.currencyFormatter.string(from: NSNumber(value: $0)) ?? "$0"}

        self.rightLabelTextColor <~ self.transactions
            .map{$0.map{$0.amount}}
            .map{$0.reduce(0, {$0 + $1})}
            .map{$0 < 0 ? .red : .green}

        let authUser = GZEAuthService.shared.authUser

        self.list <~ (
            self.transactions
                .map{
                    $0.map{trans in
                        GZEBalanceCellModel(
                            author: trans.from == authUser?.username ? trans.to : trans.from,
                            date: GZEDateHelper.displayDateTimeFormatter.string(from: trans.createdAt),
                            amount: GZENumberHelper.shared.currencyFormatter.string(from: NSNumber(value: trans.amount)) ?? "$0",
                            amountColor: trans.from == authUser?.username ? .red : .green,
                            status: trans.status
                        )
                    }
                }
        )
    }

    // Private Methods
    func updateBalance() {
        self.loading.value = true
        self.transactionsRepository.findMine().start {[weak self] in
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
