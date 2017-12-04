//
//  GZEApiStorageResponse.swift
//  Gooze
//
//  Created by Yussel on 12/1/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import Gloss

class GZEApiStorageResponse: Gloss.Decodable {
    var files = Dictionary<String, GZEFile?>()
    var fields = [String]()

    required init?(json: JSON) {

        if
            let result = json["result"] as? JSON,
            let files = result["files"] as? JSON
        {

            self.files = files.mapValues { (value) -> GZEFile? in

                guard
                    let jsonArray = value as? [JSON],
                    let files = [GZEFile].from(jsonArray: jsonArray),
                    let file = files.first
                else {
                    return nil
                }

                return file
            }
        }


    }
}
