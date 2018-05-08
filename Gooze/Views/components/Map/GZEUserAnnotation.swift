//
//  GZEUserAnnotation.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/3/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import MapKit
import ReactiveSwift

class GZEUserAnnotation: NSObject, MKAnnotation {

    dynamic var coordinate = CLLocationCoordinate2D()
    var user: GZEChatUser?

    override init() {
        super.init()
    }
}
