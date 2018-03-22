//
//  GZESocketManager.swift
//  Gooze
//
//  Created by Yussel on 3/19/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import SocketIO

class GZESocketManager: NSObject {
    static let shared = SocketClientManager.sharedManager

    static func createDateSocket() {
        if let dateSocket = shared[DatesSocket.namespace] {
            log.debug("date socket already exists, verifying connection")

            if dateSocket.status == .connected || dateSocket.status == .connecting {
                log.debug("Socket already connected or connecting. No action will be taken.")
            } else {
                dateSocket.connect()
            }
        }

        log.debug("Creating date socket..")
        let socket = DatesSocket(socketURL: URL(string: GZEAppConfig.goozeApiUrl)!, config: [.compress, .log(false)])

        socket.joinNamespace(DatesSocket.namespace)
        socket.connect()

        shared.addSocket(socket, labeledAs: DatesSocket.namespace)
    }

    static func destroyDateSocket() {
        destroySocket(withLabel: DatesSocket.namespace)
    }

    static func createChatSocket() {
        destroySocket(withLabel: ChatSocket.namespace)
    }

    static func destroySocket(withLabel label: String) {
        if let socket = GZESocketManager.shared.removeSocket(withLabel: label) {
            socket.removeAllHandlers()
            socket.disconnect()
            log.debug("Socket with label [\(label)] dstroyed")
        } else {
            log.debug("Socket with label [\(label)] not found")
        }
    }
}
