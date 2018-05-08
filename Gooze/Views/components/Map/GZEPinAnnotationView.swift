//
//  GZEPinAnnotationView.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/7/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import MapKit

class GZEPinAnnotationView: MKAnnotationView {
    dynamic let pinImageView = UIImageView(image: #imageLiteral(resourceName: "pin-w-shadow"))

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.initProperties()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initProperties()
    }

    private func initProperties() {
        self.frame = CGRect(x: 0, y: 0, width: 23, height: 52)
        self.centerOffset = CGPoint(x: 0, y: -21)

        self.pinImageView.frame = CGRect(x: 0, y: 0, width: 55, height: 52)

        self.addSubview(self.pinImageView)
    }
}
