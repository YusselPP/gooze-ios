//
//  GZESearchGoozeViewModel.swift
//  Gooze
//
//  Created by Yussel Paredes on 10/25/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation

class GZESearchGoozeViewModel {

    let userRepository: GZEUserRepositoryProtocol

    init(_ userRepository: GZEUserRepositoryProtocol) {
        self.userRepository = userRepository

        log.debug("\(self) init")
    }
    
    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
