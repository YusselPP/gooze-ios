//
//  GZEWebViewModelTerms.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/16/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZEWebViewModelTerms: GZEWebViewModel {
    let titleLabelText = MutableProperty<String?>("vm.web.terms".localized().uppercased())
    let urlRequest = URLRequest(
        url: URL(string: "\(GZEAppConfig.goozeUrl)")!
            .appendingPathComponent("terms.html")
    )
}
