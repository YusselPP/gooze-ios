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
    
    static func getSocketConfig() -> SocketIOClientConfiguration {
        var config: SocketIOClientConfiguration = [.compress, .log(false)]
        
        if let socketPath = GZEAppConfig.socketPath {
            config.insert(.path(socketPath))
        }
        
        return config
    }

    static func createSockets() {
        createDateSocket()
        createChatSocket()
    }

    static func destroyAllSockets() {
        destroyDateSocket()
    }

    static func createDateSocket() {
        if let dateSocket = shared[DatesSocket.namespace] {
            log.debug("Dates socket already exists, verifying connection")

            if dateSocket.status == .connected || dateSocket.status == .connecting {
                log.debug("Socket already connected or connecting. No action will be taken.")
            } else {
                dateSocket.connect()
            }
            return
        }

        log.debug("Creating dates socket..")
        let socket = DatesSocket(socketURL: URL(string: GZEAppConfig.goozeApiUrl)!, config: getSocketConfig())

        socket.joinNamespace(DatesSocket.namespace)
        socket.connect()

        shared.addSocket(socket, labeledAs: DatesSocket.namespace)
    }

    static func destroyDateSocket() {
        destroySocket(withLabel: DatesSocket.namespace)
    }

    static func createChatSocket() {
        if let chatSocket = shared[ChatSocket.namespace] {
            log.debug("Cht socket already exists, verifying connection")

            if chatSocket.status == .connected || chatSocket.status == .connecting {
                log.debug("Socket already connected or connecting. No action will be taken.")
            } else {
                chatSocket.connect()
            }
            return
        }

        log.debug("Creating chat socket..")
        let socket = ChatSocket(socketURL: URL(string: GZEAppConfig.goozeApiUrl)!, config: getSocketConfig())

        socket.joinNamespace(ChatSocket.namespace)
        socket.connect()

        shared.addSocket(socket, labeledAs: ChatSocket.namespace)
    }

    static func destroyChatSocket() {
        destroySocket(withLabel: ChatSocket.namespace)
    }

    static func destroySocket(withLabel label: String) {
        if let socket = GZESocketManager.shared.removeSocket(withLabel: label) {
            socket.removeAllHandlers()
            socket.disconnect()
            log.debug("Socket with label [\(label)] destroyed")
        } else {
            log.debug("Socket with label [\(label)] not found")
        }
    }
}
