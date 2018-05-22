//
//  GZERateComment.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/21/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Gloss

struct GZERateComment: Glossy {

    let id: String
    let text: String

    func localizedText() -> String {
        return self.text.localized()
    }

    // MARK: - Glossy protocol
    init?(json: JSON) {
        guard
            let id: String = "id" <~~ json,
            let text: String = "text" <~~ json
            else {
                log.error("unable to instantiate. invalid json")
                return nil
        }

        self.id = id
        self.text = text
    }

    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> self.id,
            "text" ~~> self.text
            ])
    }
}
