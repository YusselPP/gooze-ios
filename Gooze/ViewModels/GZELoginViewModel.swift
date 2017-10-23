//
//  GZELoginViewModel.swift
//  Gooze
//
//  Created by Yussel on 10/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result
import ReactiveCocoa

class GZELoginViewModel {
    enum TestError: Error {
        case error1
    }

    var user: GZEUser?

    var i = 0
    let username: MutableProperty<String?> = MutableProperty("")
    let password: MutableProperty<String?> = MutableProperty("")
    let errorMessage: MutableProperty<String?> = MutableProperty("")

    var postAction = Action<String, String, TestError>(enabledIf: MutableProperty(true)) { input in
        log.debug(input)
        return SignalProducer<String, TestError> { sink, disposable in
            sink.send(value: "Hello")
            sink.send(error: TestError.error1)
            sink.sendCompleted()
        }
    }

    init() {
        postAction.errors.observeValues { err in
            log.debug(err)
            self.i = self.i + 1
            self.errorMessage.value = "oh \((self.i))"
        }
    }


    //func login() -> Action<(), NSData, NSError> {
    //    log.debug("login called")
    //    return postAction
    //}
}
