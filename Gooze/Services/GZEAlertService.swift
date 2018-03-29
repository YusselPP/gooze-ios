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
    private let topAlert = GZEValidationErrorView()
    private let actionAlert = GZEActionAlertView()

    func showBottomAlert(superview: UIView, text: String) {
        superview.addSubview(self.bottomAlert)
        self.bottomAlert.heightAnchor.constraint(equalToConstant: 60).isActive = true
        superview.widthAnchor.constraint(equalTo: self.bottomAlert.widthAnchor).isActive = true
        superview.bottomAnchor.constraint(equalTo: self.bottomAlert.bottomAnchor).isActive = true
        superview.centerXAnchor.constraint(equalTo: self.bottomAlert.centerXAnchor).isActive = true

        self.bottomAlert.text = text
    }

    func dismissBottomAlert() {
        self.bottomAlert.dismiss()
    }

    func showTopAlert(superview: UIView, text: String) {
        superview.addSubview(self.topAlert)
        self.topAlert.textLabel.numberOfLines = 4
        //self.topAlert.heightAnchor.constraint(equalToConstant: 70).isActive = true
        self.topAlert.heightAnchor.constraint(equalTo: self.topAlert.textLabel.heightAnchor, multiplier: 1.1).isActive = true
        superview.widthAnchor.constraint(equalTo: self.topAlert.widthAnchor).isActive = true
        superview.topAnchor.constraint(equalTo: self.topAlert.topAnchor).isActive = true
        superview.centerXAnchor.constraint(equalTo: self.topAlert.centerXAnchor).isActive = true

        self.topAlert.text = text
    }

    func dismissTopAlert() {
        self.topAlert.dismiss()
    }

    func showActionAlert(superview: UIView, text: String) {
        superview.addSubview(self.actionAlert)

        superview.widthAnchor.constraint(equalTo: self.actionAlert.widthAnchor).isActive = true
        superview.centerYAnchor.constraint(equalTo: self.actionAlert.centerYAnchor).isActive = true
        superview.centerXAnchor.constraint(equalTo: self.actionAlert.centerXAnchor).isActive = true

        self.actionAlert.text = text
    }

    func dismissActionAlert() {
        self.actionAlert.dismiss()
    }
    
}
