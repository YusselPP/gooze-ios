//
//  GZEProfileViewModelReadOnly.swift
//  Gooze
//
//  Created by Yussel on 3/5/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

class GZEProfileViewModelReadOnly: NSObject, GZEProfileViewModel {

    // MARK - GZEProfileViewModel protocol
    let mode = MutableProperty<GZEProfileMode>(.contact)
    let error = MutableProperty<String?>(nil)

    let contactButtonTitle = "vm.profile.contactTitle".localized().uppercased()
    let acceptRequestButtonTitle = "vm.profile.acceptRequestTitle".localized().uppercased()

    var chatViewModel: GZEChatViewModel {
        return GZEChatViewModelDates(mode: .gooze, recipient: self.user)
    }
    
    func contact() {
        guard let userId = user.id else {
            log.error("User in profile doesn't have an id")
            error.value = GZERepositoryError.UnexpectedError.localizedDescription
            return
        }
        GZEDatesService.shared.requestDate(to: userId)
    }

    func acceptRequest() {
        guard let userId = user.id else {
            log.error("User in profile doesn't have an id")
            error.value = GZERepositoryError.UnexpectedError.localizedDescription
            return
        }
        
        GZEDatesService.shared.acceptDateRequest(from: userId)
    }
    
    func observeMessages() {
        var messages: [Signal<String?, NoError>] = []

        messages.append(GZEDatesService.shared.message.signal)
        messages.append(GZEDatesService.shared.errorMessage.signal)
        
        self.stopObservingMessages()
        self.messagesObserver = self.error <~ Signal.merge(messages).map{msg -> String? in
            log.debug("Message received: \(String(describing: msg))")
            return msg
        }
    }
    
    func stopObservingMessages() {
        self.messagesObserver?.dispose()
    }
    
    let user: GZEUser

    var messagesObserver: Disposable?

    // MARK - init
    init(user: GZEUser) {
        self.user = user
        super.init()
        log.debug("\(self) init")
    }
    
    

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
