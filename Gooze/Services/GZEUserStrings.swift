//
//  GZEUserStrings.swift
//  Gooze
//
//  Created by Yussel on 11/10/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import Localize_Swift

enum Messages: String {
    case message
}

enum Labels {

    enum Login {
        case viewTitle
        case loginButtonTitle
        case signUpButtonTitle
        case displayOkTitle
    }

    case login
}

extension Labels.Login {
    public var localizedDescription: String {
        switch self {
        case .viewTitle:
            return "label.login.viewTitle".localized()
        case .loginButtonTitle:
            return "label.login.loginButtonTitle".localized()
        case .signUpButtonTitle:
            return "label.login.signUpButtonTitle".localized()
        case .displayOkTitle:
            return "label.login.displayOkTitle".localized()
        }
    }
}
