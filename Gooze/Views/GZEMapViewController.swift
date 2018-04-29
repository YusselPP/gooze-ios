//
//  GZEMapViewController.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/20/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import MapKit
import ReactiveSwift
import ReactiveCocoa

class GZEMapViewController: UIViewController, MKMapViewDelegate {

    var viewModel: GZEMapViewModel!
    var onDismissTapped: (() -> ())?

    var mapView: MKMapView!
    let isUserInteractionEnabled = MutableProperty<Bool>(false)

    let backButton = GZEBackUIBarButtonItem()

    @IBOutlet weak var navItem: UINavigationItem!


    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var topSliderContainer: UIView!

    @IBOutlet weak var mapViewContainer: UIView!
    
    @IBOutlet weak var bottomButton: GZEButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.debug("\(self) init")
        self.setupInterfaceObjects()
        self.setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initMapKit()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.deinitMapKit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupInterfaceObjects() {
        self.backButton.onButtonTapped = {[weak self] _ in
            self?.onDismissTapped?()
        }
        self.navItem.setLeftBarButton(self.backButton, animated: false)

        self.topLabel.font = GZEConstants.Font.main
        self.topLabel.textColor = .black

        self.bottomButton.setGrayFormat()
    }

    private func setupBindings() {
        self.viewModel.dismissSignal.observeValues{[weak self] _ in
            self?.onDismissTapped?()
        }

        // actions
        self.bottomButton.reactive.pressed = self.viewModel.bottomButtonAction
    }

    // MARK - MapKit

    func initMapKit() {
        self.mapView = GZEMapService.shared.mapView
        // TODO: move delegate to vm
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true

        GZEMapService.shared.disposables.append(
            self.mapView.reactive.isUserInteractionEnabled <~ self.isUserInteractionEnabled
        )

        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        self.mapViewContainer.addSubview(self.mapView)
        self.mapViewContainer.topAnchor.constraint(equalTo: self.mapView.topAnchor).isActive = true
        self.mapViewContainer.bottomAnchor.constraint(equalTo: self.mapView.bottomAnchor).isActive = true
        self.mapViewContainer.leadingAnchor.constraint(equalTo: self.mapView.leadingAnchor).isActive = true
        self.mapViewContainer.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor).isActive = true
    }

    func deinitMapKit() {
        GZEMapService.shared.cleanMap()
        self.mapView = nil
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    deinit {
        log.debug("\(self) disposed")
    }
}
