//
//  GZEMapViewModel.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/20/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import MapKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

protocol GZEMapViewModel: MKMapViewDelegate {

    var topSliderHidden: MutableProperty<Bool> { get }

    var topLabelText: MutableProperty<String?> { get }
    var topLabelHidden: MutableProperty<Bool> { get }

    var bottomButtonTitle: MutableProperty<String> { get }
    var bottomButtonAction: CocoaAction<GZEButton>? { get }
    var bottomButtonActionEnabled: MutableProperty<Bool> { get }
    var dismissSignal: Signal<Bool, NoError> { get }

    var isMapUserInteractionEnabled: MutableProperty<Bool> { get }
    var userAnnotationLocation: MutableProperty<CLLocationCoordinate2D> { get }
    var annotationUser: MutableProperty<GZEChatUser?> { get }

    func viewWillAppear()
    func viewDidDisappear()
}
