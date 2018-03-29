//
//  GZEDatesService.swift
//  Gooze
//
//  Created by Yussel on 3/27/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import SocketIO
import ReactiveSwift

class GZEDatesService: NSObject {

    static let shared = GZEDatesService()

    let lastReceivedRequest = MutableProperty<GZEDateRequest?>(nil)
    let receivedRequests = MutableProperty<Set<GZEDateRequest>>([])

    var dateSocket: SocketIOClient? {
        return GZESocketManager.shared[DatesSocket.namespace]
    }

    override init() {
        super.init()
//        lastReceivedRequest.signal.observeValues { dateRequest in
//            if let topView = UIApplication.topViewController()?.view {
//                GZEAlertService.shared.showActionAlert(superview: topView, text: "Date request received")
//            }
//        }
    }

    func requestDate(to userId: String) {
        guard let dateSocket = self.dateSocket else {
            log.error("Date socket not found")
            return
        }

        dateSocket.emitWithAck(.dateRequestSent, userId).timingOut(after: 5) { data in
            log.debug("ack data: \(data)")
        }
    }
}
