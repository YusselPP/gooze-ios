//
//  GZESocket.swift
//  Gooze
//
//  Created by Yussel on 3/17/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import SocketIO
import Gloss

class GZESocket: SocketIOClient {

    enum Event: String {
        case authentication
        case authenticated
        case unauthorized
    }

    var topViewController: UIViewController? {
        return UIApplication.topViewController()
    }

    let dateRequestReceivedUser = MutableProperty<GZEUser?>(nil)


    // MARK - init
    override init(socketURL: URL, config: SocketIOClientConfiguration) {
        super.init(socketURL: socketURL, config: config)
        log.debug("\(self) init")
        self.addEventHandlers()
    }

    private func addEventHandlers() {
        self.on(clientEvent: .connect) {data, ack in

            log.debug("socket connected")

            guard let accessToken = GZEApi.instance.accessToken else {
                log.debug("No authenticated user found in the app")
                log.debug("Socket will be disconected")
                return
            }

            log.debug("Socket authentication started")
            self.emit(.authentication, ["id": accessToken.id, "userId": accessToken.userId])
        }

        self.on(clientEvent: .disconnect) {data, ack in
            log.error("Socket disconnected. Removing all event handlers")
            self.removeAllHandlers()
        }

        self.on(clientEvent: .reconnect) {data, ack in
            log.debug("Reconecting...")
        }

        self.on(.authenticated) {data, ack in
            log.debug("Socket is authenticated");
        }

        self.on(.unauthorized) {data, ack in
            log.error("Socket failed authentication. Reason: \(data[0])")
        }
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}

extension SocketIOClient {

    func emit(_ clientEvent: GZESocket.Event, _ items: SocketData...) {

        emit(clientEvent.rawValue, items)
    }

    @discardableResult
    func on(_ clientEvent: GZESocket.Event, callback: @escaping NormalCallback) -> UUID {

        return on(clientEvent.rawValue, callback: callback)
    }

}
