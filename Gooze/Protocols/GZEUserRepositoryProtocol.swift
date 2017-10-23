//
//  GZEUserRepositoryProtocol.swift
//  Gooze
//
//  Created by Yussel on 10/22/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation

protocol GZEUserRepositoryProtocol {

    static func login(_ username: String, _ password: String) -> GZEUser
}
