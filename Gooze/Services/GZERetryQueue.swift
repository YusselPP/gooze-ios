//
//  GZERetryQueue.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 7/5/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

class GZERetryQueue {

    let timeInterval: TimeInterval = 5

    private var queue = [CompletionBlock]()
    private var timer: Timer?


    func push(element: @escaping CompletionBlock) {
        queue.append(element)
        guard timer == nil || !timer!.isValid else {
            return
        }
        startTimer()
    }

    func startTimer() {
        if timer != nil && timer!.isValid  {
            log.debug("Timer already running, stopping current timer")
            stopTimer()
        }

        log.debug("Creating timer")
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: false)
        log.debug("Timer created")
    }

    func stopTimer() {
        guard timer != nil else {
            return
        }
        timer!.invalidate()
        timer = nil
    }

    @objc func timerCallback() {
        log.debug("Timer callback called. queue.count: \(queue.count)")
        for cb in queue {
            DispatchQueue.main.async {
                cb()
            }
        }
        log.debug("Timer callback ended. queue.count: \(queue.count)")
        queue.removeAll()
    }

    func clear() {
        stopTimer()
        queue.removeAll()
    }
}
