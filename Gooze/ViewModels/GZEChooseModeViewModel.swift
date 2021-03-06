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

    let goozeHelpLabelText = "vm.chooseMode.goozeHelpText".localized()
    let clientHelpLabelText = "vm.chooseMode.clientHelpText".localized()
    let beButtonTitle = "vm.chooseMode.beButtonTitle".localized()
    let searchButtonTitle = "vm.chooseMode.searchButtonTitle".localized()

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

    func getLoginViewModel() -> GZELoginViewModel {
        return GZELoginViewModel(userRepository)
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
