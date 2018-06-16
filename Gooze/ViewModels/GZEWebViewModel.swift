//
//  GZEWebViewModel.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/16/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

protocol GZEWebViewModel {
    var titleLabelText: MutableProperty<String?> {get}
    var urlRequest: URLRequest {get}
}
