//
//  GZEUserRepository.swift
//  Gooze
//
//  Created by Yussel on 10/23/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import LoopBack

class GZEUserRepository: LBPersistedModelRepository {

    var accessTokenRepository: LBAccessTokenRepository?
    var currentUserId: String?

    override init() {
        super.init(className: "GoozeUsers")
    }

    static func repository() -> GZEUserRepository {
        return GZEUserRepository()
    }

    func login(
        email: String,
        password: String,
        success: @escaping LBUserLoginSuccessBlock,
        failure: @escaping SLFailureBlock) {

        log.debug("login called " + email + " " + password)
        self.invokeStaticMethod("login", parameters: ["include": "user"], bodyParameters: ["email": email, "password": password], success: { (value) in
            let adapter = self.adapter as! LBRESTAdapter;
            if self.accessTokenRepository == nil {
                self.accessTokenRepository = (adapter.repository(with: LBAccessTokenRepository.self) as! LBAccessTokenRepository)
            }
            let accessToken = self.accessTokenRepository?.model(with: value as! [AnyHashable : Any]) as! LBAccessToken
            adapter.accessToken = accessToken._id as? String;
            self.currentUserId = accessToken.userId
            success(accessToken);
        }, failure: failure)
    }
}
