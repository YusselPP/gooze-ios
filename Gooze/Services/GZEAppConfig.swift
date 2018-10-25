//
//  GZEAppConfig.swift
//  Gooze
//
//  Created by Yussel on 10/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//
import Foundation
import ReactiveSwift
import Alamofire
import Gloss

class GZEAppConfig {
    private static var config: [String: Any]?

    enum Environments: String {
        case debug = "Debug"
        case staging = "Staging"
        case release = "Release"
    }

    private static var _environment: Environments?

    static var environment: Environments {
        var config: String?

        if _environment != nil {
            return _environment!
        }

        config = Bundle.main.object(forInfoDictionaryKey: "Config") as? String

        switch config {
        case .some(Environments.debug.rawValue):
            _environment = .debug
        case .some(Environments.staging.rawValue):
            _environment = .staging
        case .some(Environments.release.rawValue):
            _environment = .release
        default:
            _environment = .debug
            NSLog("Config = $(CONFIGURATION) property not defined in Info.plist. Using defaults")
        }

        NSLog("Using \(_environment!.rawValue) environment")

        return _environment!
    }

    static var logLevel: String {
        return getValue("LogLevel", defaultValue: "error")
    }

    static var logAppID: String {
        return getValue("LogAppID", defaultValue: "")
    }

    static var logAppSecret: String {
        return getValue("LogAppSecret", defaultValue: "")
    }

    static var logAppKey: String {
        return getValue("LogAppKey", defaultValue: "")
    }

    static var goozeUrl: String {
        return getValue("GoozeUrl", defaultValue: "http://localhost:3000/")
    }

    static var goozeApiUrl: String {
        return getValue("GoozeApiUrl", defaultValue: "http://localhost:3000/api")
    }

    static var useRegisterCode: Bool {
        return getValue("useRegisterCode", defaultValue: true)
    }

    static var appTitle: String {
        return getValue("AppTitle", defaultValue: "Gooze")
    }
    
    // "/staging/socket.io"
    static var socketPath: String? {
        return getValue("SocketPath", defaultValue: nil)
    }

    static var conektaPublicKey: String {
        return getValue("ConektaPublicKey", defaultValue: "")
    }


    // Mark: Load config file
    static func load() -> Void {
        let fileName = environment.rawValue
        let fileExtension = "plist"
        let errorMessage = "Unable to load configuration from: \(fileName).\(fileExtension)"

        guard
            let fileUrl = Bundle.main.url(forResource: fileName, withExtension: "plist"),
            let data = try? Data(contentsOf: fileUrl),
            let propertyList = try? PropertyListSerialization.propertyList(from: data, format: nil),
            let appConfig = propertyList as? [String: Any]
        else {
            NSLog(errorMessage)
            return
        }
        config = appConfig;
    }

    static func loadRemote() -> SignalProducer<JSON, GZEError> {
        return SignalProducer {sink, disposable in
            Alamofire.request(GZEAppConfigRouter.find(byName: environment.rawValue))
                .responseJSON(completionHandler: GZEApi.createResponseHandler(sink: sink, createInstance: {
                    "config" <~~ $0
                }))
        }
    }


    // Mark: Private methods
    private static func getValue<T>(_ key: String, defaultValue: T) -> T {
        if let value = config?[key] as? T {
            return value
        }
        return defaultValue
    }
}
