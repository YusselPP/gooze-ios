//
//  GZEHistoryDetailViewModelDates.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 11/11/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZEHistoryDetailViewModelDates: GZEHistoryDetailViewModel {

    // GZEHistoryDetailViewModel protocol
    let loading = MutableProperty<Bool>(false)
    let error = MutableProperty<String?>(nil)

    let bottomActionButtonIsHidden = MutableProperty<Bool>(false)
    let bottomActionButtonTitle = MutableProperty<String>("")
    var bottomActionButtonAction: CocoaAction<GZEButton>?

    let username = MutableProperty<String?>(nil)
    let status = MutableProperty<String?>(nil)
    let date = MutableProperty<String?>(nil)
    let amount = MutableProperty<String?>(nil)
    let address = MutableProperty<String?>(nil)


    let (didLoadSignal, didLoadObs) = Signal<Void, NoError>.pipe()
    let (dismissSignal, dismissObs) = Signal<Void, NoError>.pipe()
    let (segueToHelp, segueToHelpObs) = Signal<GZEHelpViewModel, NoError>.pipe()
    // END GZEHistoryDetailViewModel protocol

    // private
    let actionHelpTitle = "vm.history.detail.action.help".localized()

    let dateRequest: GZEDateRequest
    let isActionButtonEnabled = MutableProperty<Bool>(false)


    // MARK - init
    init(dateRequest: GZEDateRequest, mode: GZEChatViewMode) {
        self.dateRequest = dateRequest
        log.debug("\(self) init")

        self.bottomActionButtonTitle.value = (
            dateRequest.transaction?.goozeStatus == .review ?
                GZETransaction.GoozeStatus.review.localizedDescription :
                actionHelpTitle
        ).uppercased()
        self.bottomActionButtonIsHidden.value = dateRequest.date?.status != .canceled || dateRequest.transaction?.goozeStatus == .paid
        self.isActionButtonEnabled.value = (
            dateRequest.transaction?.goozeStatus != .review
        )

        self.bottomActionButtonAction = CocoaAction(Action(enabledIf: isActionButtonEnabled){SignalProducer<Void, GZEError>{[weak self] sink, dispose in
            guard let this = self else {
                sink.send(error: .repository(error: .UnexpectedError))
                return
            }
            this.segueToHelpObs.send(value: GZEHelpViewModelGooze(dateRequest: this.dateRequest))
            sink.send(value: ())
            sink.sendCompleted()
        }})

        self.username.value = mode == .client ? dateRequest.recipient.username : dateRequest.sender.username
        self.status.value = dateRequest.date?.status.localizedDescription ?? ""
        if let createdAt = dateRequest.date?.createdAt {
            self.date.value =  GZEDateHelper.displayDateTimeFormatter.string(from: createdAt)
        }
        self.amount.value = dateRequest.amount?.toCurrencyString()
        dateRequest.location.toCLLocation().toAddress().start{[weak self] event in
            log.debug("event: \(event)")
            guard let this = self else {return}

            switch event {
            case .value(let address):
                this.address.value = address
            case .failed(let error):
                this.error.value = error.localizedDescription
            default: break
            }
        }
    }

    // MARK: - Deinitializers
    deinit {
        GZEDatesService.shared.activeRequest = nil
        log.debug("\(self) disposed")
    }
}
