//
//  CollectionEvent.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/18/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

enum CollectionEvent: CustomStringConvertible {
    
    case add(at: Int, count: Int)
    case remove(at: Int, count: Int)
    case update(at: Int, count: Int)
    
    var description: String {
        switch self {
        case .add(let at, let count):
            return "add(at: \(at), count: \(count)"
        case .remove(let at, let count):
            return "remove(at: \(at), count: \(count)"
        case .update(let at, let count):
            return "update(at: \(at), count: \(count)"
        }
    }
}
