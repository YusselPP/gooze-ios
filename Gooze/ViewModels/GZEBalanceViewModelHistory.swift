//
//  GZEBalanceViewModelHistory.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 11/8/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZEBalanceViewModelHistory: GZEBalanceViewModel {

    // GZEBalanceViewModel protocol
    let error = MutableProperty<String?>(nil)
    let loading = MutableProperty<Bool>(false)
    let (viewShown, viewShownObs) = Signal<Bool, NoError>.pipe()
    let (dismiss, dismissObs) = Signal<Void, NoError>.pipe()
    let title = MutableProperty<String?>(nil)
    let navigationRightButton = MutableProperty<UIBarButtonItem?>(nil)

    let list = MutableProperty<[GZEBalanceCellModel]>([])
    let rightLabelText = MutableProperty<String?>(nil)
    let rightLabelTextColor = MutableProperty<UIColor>(.white)
    let bottomStackHidden = MutableProperty<Bool>(true)

    let dataAtBottom = false
    // END GZEBalanceViewModel protocol

    // Private properties
    let mode: GZEChatViewMode
    let dateRequestRepository: GZEDateRequestRepositoryProtocol = GZEDateRequestApiRepository()
    let dateRequests = MutableProperty<[GZEDateRequest]>([])
    lazy var findTransactions: () -> SignalProducer<[GZEDateRequest], GZEError> = {
        if self.mode == .gooze {
            return self.dateRequestRepository.goozeHistory
        } else {
            return self.dateRequestRepository.clientHistory
        }
    }()

    init(mode: GZEChatViewMode) {
        self.mode = mode

        log.debug("\(self) init")

        self.title.value = "vm.balance.history.title".localized()

        self.viewShown.signal.observeValues {[weak self] shown in
            guard let this = self else {return}
            if shown {
                this.updateBalance()
            }
        }

        self.list <~ (
            self.dateRequests
                .map{
                    $0.map{dateRequest in

                        var date = ""
                        if let createdAt = dateRequest.date?.createdAt {
                            date = GZEDateHelper.displayDateTimeFormatter.string(from: createdAt)
                        }

                        return GZEBalanceCellModel(
                            author: mode == .gooze ? dateRequest.sender.username : dateRequest.recipient.username,
                            date: date,
                            amount: dateRequest.amount?.toCurrencyString() ?? "$0",
                            amountColor: .white,
                            status: dateRequest.date?.status.localizedDescription ?? ""
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
            case .value(let dateRequests):
                this.dateRequests.value = dateRequests
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
