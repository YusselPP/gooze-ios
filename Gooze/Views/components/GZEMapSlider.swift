//
//  GZEMapSlider.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/6/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEMapSlider: UISlider {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initProperties()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initProperties()
    }

    init() {
        super.init(frame: CGRect.zero)
        initProperties()
    }
    
    private func initProperties() {
        self.setThumbImage(#imageLiteral(resourceName: "slider-thumb"), for: .normal)
        self.setThumbImage(#imageLiteral(resourceName: "slider-thumb"), for: .highlighted)
    }
}
