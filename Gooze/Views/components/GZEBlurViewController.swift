//
//  GZEBlurViewController.swift
//  Gooze
//
//  Created by Yussel on 11/9/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

public typealias GZEBlurViewCompletion = (UIImage?) -> Void

class GZEBlurViewController: UIViewController {
    var blur: GZEBlur!

    var image: UIImage
    var onCompletion: GZEBlurViewCompletion?

    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var blurEffectView: UIView!
    @IBOutlet weak var blurRadiusSlider: UISlider!

    @IBOutlet weak var applyButton: UIBarButtonItem!
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: "GZEBlurViewController", bundle: nil)
        log.debug("\(self) init")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // applyButton.title = Labels.BlurView.applyButtonTitle.localizedDescription

        blur = GZEBlur(image: image, blurEffectView: blurEffectView, resultImageView: resultImageView)

        blurRadiusSlider.reactive.values.debounce(0.3, on: QueueScheduler.main).observeValues { [weak self] in
            self?.blur.radius = $0
        }

        blurEffectView.layer.borderWidth = 1
        blurEffectView.layer.borderColor = UIColor.white.cgColor
        blurEffectView.layer.cornerRadius = blurEffectView.frame.size.width / 2

        blurEffectView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(blurPan)))
        blurEffectView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(blurPinched)))
        blurEffectView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blur.draw()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func blurPinched(_ gestureRecognizer: UIPinchGestureRecognizer) {

        let scale = gestureRecognizer.scale

        guard let view = gestureRecognizer.view else {
            log.debug("Gesture doesn't have a view")
            return
        }

        log.debug(view.transform)
        log.debug(scale)

        let transform = view.transform.scaledBy(x: scale, y: scale)

        guard transform.a >= 1 else {
            log.debug("Reached min size")
            return
        }

        view.transform = transform
        gestureRecognizer.scale = 1

        blur.draw()
    }

    func blurPan(_ gestureRecognizer: UIPanGestureRecognizer) {

        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.view)

            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        }

        blur.draw()
    }

    @IBAction func revertButtonTapped(_ sender: UIBarButtonItem) {
        blur.revert()
    }

    @IBAction func applyButtonTapped(_ sender: UIBarButtonItem) {
        blur.apply()
    }

    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        close()
    }

    func close() {
        onCompletion?(blur.resultImage)
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
