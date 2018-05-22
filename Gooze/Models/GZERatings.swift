//
//  GZERatings.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/16/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation
import Gloss

class GZERatings: Glossy {

    var comment: GZERateComment?
    var imagesRating: Float = 0
    var complianceRating: Float = 0
    var dateQualityRating: Float = 0
    var dateRating: Float = 0
    var goozeRating: Float = 0

    init() {}

    init(
        comment: GZERateComment?,
        imagesRating: Float,
        complianceRating: Float,
        dateQualityRating: Float,
        dateRating: Float,
        goozeRating: Float
    ) {
        self.comment = comment
        self.imagesRating = imagesRating
        self.complianceRating = complianceRating
        self.dateQualityRating = dateQualityRating
        self.dateRating = dateRating
        self.goozeRating = goozeRating
    }

    required init?(json: JSON) {
        guard
            let imagesRating: Float = "imagesRating" <~~ json,
            let complianceRating: Float = "complianceRating" <~~ json,
            let dateQualityRating: Float = "dateQualityRating" <~~ json,
            let dateRating: Float = "dateRating" <~~ json,
            let goozeRating: Float = "goozeRating" <~~ json
        else {
            log.error("unable to instantiate missing required parameters")
            return nil
        }

        self.comment = "comment" <~~ json
        self.imagesRating = imagesRating
        self.complianceRating = complianceRating
        self.dateQualityRating = dateQualityRating
        self.dateRating = dateRating
        self.goozeRating = goozeRating
    }

    func toJSON() -> JSON? {
        return jsonify([
            "comment" ~~> self.comment,
            "imagesRating" ~~> self.imagesRating,
            "complianceRating" ~~> self.complianceRating,
            "dateQualityRating" ~~> self.dateQualityRating,
            "dateRating" ~~> self.dateRating,
            "goozeRating" ~~> self.goozeRating
            ])
    }
}

extension GZERatings {
    struct Rating: Glossy {
        let value: Float
        let count: Int

        var rate: Float {
            return self.value / Float(self.count)
        }

        init(value: Float, count: Int) {
            self.value = value
            self.count = count
        }

        mutating func add(_ rate: Rating) {
            self = Rating(value: self.value + rate.value, count: self.count + rate.count)
        }

        // MARK: - Glossy protocol
        init?(json: JSON) {
            guard
                let value: Double = "value" <~~ json,
                let count: Int = "count" <~~ json
                else {
                    log.error("unable to instantiate. invalid json")
                    return nil
            }

            self.value = Float(value)
            self.count = count
        }

        func toJSON() -> JSON? {
            return jsonify([
                "value" ~~> self.value,
                "count" ~~> self.count
                ])
        }
    }
}
