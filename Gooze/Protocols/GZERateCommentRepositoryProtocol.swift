//
//  GZERateCommentRepositoryProtocol.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/21/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol GZERateCommentRepositoryProtocol {
    func findAll() -> SignalProducer<[GZERateComment], GZEError>
}
