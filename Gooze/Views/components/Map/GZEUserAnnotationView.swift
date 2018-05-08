//
//  GZEUserAnnotationView.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/1/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import MapKit

class GZEUserAnnotationView: MKAnnotationView {

    let userBalloon = GZEUserBalloon()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.initProperties()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initProperties()
    }

    private func initProperties() {
        self.contentMode = .center
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalTo: self.widthAnchor).isActive = true

        self.userBalloon.translatesAutoresizingMaskIntoConstraints = false
        self.userBalloon.alpha = 1

        self.addSubview(self.userBalloon)

        self.topAnchor.constraint(equalTo: self.userBalloon.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.userBalloon.bottomAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: self.userBalloon.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: self.userBalloon.rightAnchor).isActive = true
    }

}
