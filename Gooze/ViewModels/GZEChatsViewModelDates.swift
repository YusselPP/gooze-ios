//
//  GZEChatsViewModelDates.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/23/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZEChatsViewModelDates: GZEChatsViewModel {

    // MARK: - GZEChatsViewModel protocol
    let title = MutableProperty<String?>(nil)
    let chatsList = MutableProperty<[GZEChatCellModelDates]>([])

    let error = MutableProperty<String?>(nil)
    let loading = MutableProperty<Bool>(false)

    let (dismiss, dismissObs) = Signal<Void, NoError>.pipe()
    let (segueToChat, segueToChatObs) = Signal<GZEChatViewModelDates, NoError>.pipe()

    func viewWillAppear() {
        // TODO: maybe set some dirty flag that is set while view is in foreground and getRequests() only if is dirty
        self.getDateRequests()
        self.startObservers()
    }

    func viewDidDisappear() {
        self.disposeObservers()
    }
    // END protocol GZEChatsViewModel

    // MARK: - private properties
    let chatsTitle = "menu.item.title.chats".localized().uppercased()
    let closeDateError = "vm.chats.list.error.closeDate".localized()

    let dateRequestRepository: GZEDateRequestRepositoryProtocol = GZEDateRequestApiRepository()

    let mode: GZEChatViewMode
    let dateRequests = MutableProperty<[GZEDateRequest]>([])
    let messages = MutableProperty<[String: GZEChatMessage]>([:])

    var requestsObserver: Disposable?
    var messagesObserver: Disposable?
    var socketEventsObserver: Disposable?

    // MARK: - init
    init(mode: GZEChatViewMode) {
        self.mode = mode
        log.debug("\(self) init, mode: \(mode)")

        self.title.value = self.chatsTitle
        self.chatsList <~ self.dateRequests.combineLatest(with: GZEChatService.shared.unreadCount).map{[weak self]  in
            log.debug("dateRequests changed, updating chat list")
            guard let this = self else {return []}
            let (dateRequests, unreadCount) = $0
            var list = [GZEChatCellModelDates]()
            for dateRequest in dateRequests {
                let chatUser: GZEChatUser
                switch this.mode {
                case .client: chatUser = dateRequest.recipient
                case .gooze: chatUser = dateRequest.sender
                }
                var unreadMessages = 0
                if let chatId = dateRequest.chat?.id {
                    unreadMessages = unreadCount[chatId] ?? 0
                }
                list.append(GZEChatCellModelDates(
                    id: dateRequest.id,
                    user: chatUser,
                    title: chatUser.username,
                    preview: dateRequest.chat?.messages.last?.localizedText(),
                    unreadMessages: unreadMessages,
                    onClose: {[weak self] _ in
                        self?.closeDateRequest(dateRequest)
                    },
                    onTap: {[weak self] _ in self?.onChatTapped(dateRequest, chatUser)},
                    isBlocked: dateRequest.isBlocked
                ))
            }
            return list
        }
    }

    func getDateRequests() {

        var dateRequestsProducer: SignalProducer<[GZEDateRequest], GZEError>

        if mode == .client {
            dateRequestsProducer = self.dateRequestRepository.findSentRequests(closed: false)
        } else {
            dateRequestsProducer = self.dateRequestRepository.findReceivedRequests(closed: false)
        }

        self.loading.value = true
        dateRequestsProducer.start {[weak self] event in
            log.debug("event received: \(event)")
            guard let this = self else {return}
            this.loading.value = false

            switch event {
            case .value(let dateRequests):
                this.dateRequests.value = dateRequests
            case .failed(let error):
                this.onError(error)
            default: break
            }
        }
    }

    func onError(_ error: GZEError) {
        self.error.value = error.localizedDescription
    }

    func onChatTapped(_ dateRequest: GZEDateRequest, _ chatUser: GZEChatUser) {
        log.debug("dateRequest.id: \(dateRequest.id) tapped")
        if let chat = dateRequest.chat {
            self.segueToChatObs.send(value: GZEChatViewModelDates(
                chat: chat, dateRequest: MutableProperty(dateRequest), mode: self.mode, username: chatUser.username
            ))
        } else {
            log.debug("chat nil")
        }
    }

    func closeDateRequest(_ dateRequest: GZEDateRequest) {
        guard dateRequest.status != .onDate else {
            self.error.value = self.closeDateError
            log.debug("Only rejected, ended or canceled requests can be closed")
            return
        }

        self.loading.value = true

        self.dateRequestRepository.close(dateRequest, mode: self.mode).start {[weak self]event in
            log.debug("event received \(event)")
            guard let this = self else {return}
            this.loading.value = false
            switch event {
            case .value:
                if let index = this.dateRequests.value.index(of: dateRequest) {
                    this.dateRequests.value.remove(at: index)
                } else {
                    log.warning("element not found in dateRequests array")
                }
            case .failed(let error):
                this.onError(error)
            default: break
            }
        }
    }

    func startObservers() {
        self.observeRequests()
        self.observeMessages()
        self.observeSocketEvents()
    }

    func disposeObservers() {
        self.stopObservingRequests()
        self.stopObservingMessages()
        self.stopObservingSocketEvents()
    }

    private func observeRequests() {
        var lastRequestSignal: Signal<GZEDateRequest, NoError>
        switch self.mode {
        case .client:
            lastRequestSignal = (
                GZEDatesService.shared.lastSentRequest
                    .signal.skipNil().filter{!$0.senderClosed}
            )
        case .gooze:
            lastRequestSignal = (
                GZEDatesService.shared.lastReceivedRequest
                    .signal.skipNil().filter{!$0.recipientClosed}
            )
        }

        self.stopObservingRequests()
        self.requestsObserver = (
            lastRequestSignal
                .observeValues {[weak self] updatedDateRequest in
                    log.debug("updatedDateRequest: \(String(describing: updatedDateRequest))")
                    guard let this = self else { log.error("self was disposed"); return }
                    this.dateRequests.value.upsert(updatedDateRequest){$0 == updatedDateRequest}
                }
        )
    }

    private func stopObservingRequests() {
        if self.requestsObserver != nil {
            log.debug("stop observing requests")
            self.requestsObserver?.dispose()
            self.requestsObserver = nil
        }
    }

    private func observeMessages() {
        log.debug("start observing messages")
        self.stopObservingMessages()
        self.messagesObserver = (
            GZEChatService.shared.lastMessage
                .signal
                .skipNil()
                .observeValues {[weak self] message in
                    log.debug("message received, updating dateRequests")
                    guard let this = self else { log.error("self was disposed");  return }
                    // this.messages.value[message.chatId] = message
                    let dateRequets = this.dateRequests.value.filter{$0.chat?.id == message.chatId}
                    var updatedRequests = [GZEDateRequest]()
                    dateRequets.forEach{
                        $0.chat?.messages = [message]
                        if let drJson = $0.toJSON(), let dr = GZEDateRequest(json: drJson) {
                            updatedRequests.append(dr)
                        }
                    }
                    this.dateRequests.value.upsert(contentsOf: updatedRequests){$0 == $1}
                }
        )
    }

    private func stopObservingMessages() {
        if self.messagesObserver != nil {
            log.debug("stop observing messages")
            self.messagesObserver?.dispose()
            self.messagesObserver = nil
        }
    }

    private func observeSocketEvents() {
        log.debug("start observing socket events")
        stopObservingSocketEvents()
        self.socketEventsObserver = GZEDatesService.shared.dateSocket?
            .socketEventsEmitter
            .signal
            .skipNil()
            .filter { $0 == .authenticated }
            .observeValues {[weak self] _ in
                guard let this = self else {
                    log.error("self was disposed")
                    return
                }
                this.getDateRequests()
        }
    }

    private func stopObservingSocketEvents() {
        if self.socketEventsObserver != nil {
            log.debug("stop observing SocketEvents")
            self.socketEventsObserver?.dispose()
            self.socketEventsObserver = nil
        }
    }


    // MARK: - deinit
    deinit {
        log.debug("\(self) disposed")
    }
}
