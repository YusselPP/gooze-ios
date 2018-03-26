//
//  GZEAlertService.swift
//  Gooze
//
//  Created by Yussel on 3/25/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEAlertService {
    static let shared = GZEAlertService()

    private let bottomAlert = GZEValidationErrorView()

    func showBottomAlert(superview: UIView, text: String) {
        superview.addSubview(self.bottomAlert)
        self.bottomAlert.heightAnchor.constraint(equalToConstant: 60).isActive = true
        superview.widthAnchor.constraint(equalTo: self.bottomAlert.widthAnchor).isActive = true
        superview.bottomAnchor.constraint(equalTo: self.bottomAlert.bottomAnchor).isActive = true
        superview.centerXAnchor.constraint(equalTo: self.bottomAlert.centerXAnchor).isActive = true

        self.bottomAlert.text = text
    }

    func dismissBottomAlert() {
        bottomAlert.dismiss()
    }
}
