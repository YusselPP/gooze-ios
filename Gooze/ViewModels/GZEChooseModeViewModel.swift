//
//  GZEChooseModeViewModel.swift
//  Gooze
//
//  Created by Yussel on 11/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import Localize_Swift

class GZEChooseModeViewModel {

    let userRepository: GZEUserRepositoryProtocol

    init(_ userRepository: GZEUserRepositoryProtocol) {
        self.userRepository = userRepository

        log.debug("\(self) init")
    }

    func getSearchGoozeViewModel() -> GZESearchGoozeViewModel {
        return GZESearchGoozeViewModel(userRepository)
    }

    func getActivateGoozeViewModel() -> GZEActivateGoozeViewModel {
        return GZEActivateGoozeViewModel(userRepository)
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
