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

    var coordinate = CLLocationCoordinate2D()
    var user: GZEChatUser?

    override init() {
        super.init()
    }
}

extension Reactive where Base: GZEUserAnnotation {
    var coordinate: BindingTarget<CLLocationCoordinate2D> {
        return makeBindingTarget {
            $0.coordinate = $1
        }
    }

    var user: BindingTarget<GZEChatUser?> {
        return makeBindingTarget {
            $0.user = $1
        }
    }
}
