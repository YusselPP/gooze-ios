//
//  GZEFile.swift
//  Gooze
//
//  Created by Yussel on 11/7/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import Foundation
import Gloss

class GZEFile: Glossy {
    var name: String?
    var sizeBytes: Int?
    var container: String?
    var type: String?
    var data: Data?

    var accessTime: Date?
    // modified its content
    var modifyTime: Date?
    // modified its content or attributes
    var changeTime: Date?


    required init?(json: JSON) {
        self.name = "name" <~~ json
        self.sizeBytes = "size" <~~ json
        self.container = "container" <~~ json
        self.type = "type" <~~ json


        self.accessTime = Decoder.decode(dateForKey: "atime", dateFormatter: GZEApi.dateFormatter)(json)
        self.modifyTime = Decoder.decode(dateForKey: "mtime", dateFormatter: GZEApi.dateFormatter)(json)
        self.changeTime = Decoder.decode(dateForKey: "ctime", dateFormatter: GZEApi.dateFormatter)(json)
    }

    func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> self.name,
            "size" ~~> self.sizeBytes,
            "container" ~~> self.container,
            "type" ~~> self.type,
            Encoder.encode(dateForKey: "atime", dateFormatter: GZEApi.dateFormatter)(self.accessTime),
            Encoder.encode(dateForKey: "mtime", dateFormatter: GZEApi.dateFormatter)(self.modifyTime),
            Encoder.encode(dateForKey: "ctime", dateFormatter: GZEApi.dateFormatter)(self.changeTime)
        ])
    }

    func asUIImage() -> UIImage? {
        guard let data = self.data else {
            return nil
        }
        return UIImage(data: data)
    }
}
