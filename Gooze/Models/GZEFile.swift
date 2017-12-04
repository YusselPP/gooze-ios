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
    var name: String
    var sizeBytes: Int
    var container: String
    var type: String

    var data: Data?

    var accessTime: Date?
    // modified its content
    var modifyTime: Date?
    // modified its content or attributes
    var changeTime: Date?

    var persisted = false

    init(name: String, size: Int, container: String, type: String, data: Data?){
        self.name = name
        self.sizeBytes = size
        self.container = container
        self.type = type

        self.data = data
    }

    required init?(json: JSON) {

        guard
            let name: String = "name" <~~ json,
            let sizeBytes: Int = "size" <~~ json,
            let container: String = "container" <~~ json,
            let type: String = "type" <~~ json
        else {
            log.error("GZEFile init failed due to missing required fields.")
            return nil
        }
        
        self.name = name
        self.sizeBytes = sizeBytes
        self.container = container
        self.type = type


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
