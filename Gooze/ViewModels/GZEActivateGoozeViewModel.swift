//
//  GZEActivateGoozeViewModel.swift
//  Gooze
//
//  Created by Yussel on 11/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation

class GZEActivateGoozeViewModel {

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
