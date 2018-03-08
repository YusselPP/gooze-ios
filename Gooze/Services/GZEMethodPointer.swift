//
//  GZEMethodPointer.swift
//  Gooze
//
//  Created by Yussel on 2/25/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

func ptr<T: AnyObject, V>(_ obj: T, _ method: @escaping (T) -> () -> V) -> (() -> V) {
    return { [weak obj] in
        if obj == nil {
            log.error("Unexpected nil object found")
        }
        return method(obj!)()
    }
}

func ptr<T: AnyObject, U>(_ obj: T, _ method: @escaping (T) -> (U) -> Void) -> ((U) -> Void) {
    return { [weak obj] arg in
        if obj == nil {
            log.error("Unexpected nil object found")
        }
        method(obj!)(arg)
    }
}

func ptr<T: AnyObject, U, V>(_ obj: T, _ method: @escaping (T) -> (U) -> V) -> ((U) -> V) {
    return { [weak obj] arg in
        if obj == nil {
            log.error("Unexpected nil object found")
        }
        return method(obj!)(arg)
    }
}

