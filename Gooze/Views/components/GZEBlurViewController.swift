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

    var image: UIImage
    var onCompletion: GZEBlurViewCompletion?

    var isBlurInitiliazed = false

    let ciContext = CIContext(options: nil)

    let filter = CIFilter(name: "CIMaskedVariableBlur")!

    var blurRadius: Float = 15 {
        didSet {
            filter.setValue(blurRadius, forKey: kCIInputRadiusKey)
        }
    }

    var resultImage: UIImage? {
        didSet {
            var ciImage: CIImage?
            if let resultImage = self.resultImage {
                ciImage = CIImage(image: resultImage)
            }
            filter.setValue(ciImage, forKey: kCIInputImageKey)
        }
    }

    let minimumBlurSize = CGSize(width: 60, height: 60)

    var heightConstraint: NSLayoutConstraint!

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
        applyButton.title = Labels.BlurView.applyButtonTitle.localizedDescription


        blurRadiusSlider.reactive.values.debounce(0.3, on: QueueScheduler.main).observeValues { [weak self] in
            self?.blurRadius = $0
            self?.drawBlur()
        }

        blurRadius = 15
        resultImage = image
        resultImageView.image = resultImage

        blurEffectView.layer.borderWidth = 1
        blurEffectView.layer.borderColor = UIColor.white.cgColor
        blurEffectView.layer.cornerRadius = blurEffectView.frame.size.width / 2

        blurEffectView.addGestureRecognizer(createGestureRecognizer())
        blurEffectView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(blurPinched(_:))))

        //heightConstraint = blurEffectView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor, multiplier: 0.2)
        heightConstraint = blurEffectView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        heightConstraint.isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        drawBlur()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        drawBlur()
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

        drawBlur()
    }

    func blurPan(_ gestureRecognizer: UIPanGestureRecognizer) {

        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self.view)

            gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        }

        drawBlur()
    }

    @IBAction func revertButtonTapped(_ sender: UIBarButtonItem) {
        resultImage = image
        drawBlur()
    }

    @IBAction func applyButtonTapped(_ sender: UIBarButtonItem) {
        resultImage = resultImageView.image
        drawBlur()
    }

    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        close()
    }

    func close() {
        onCompletion?(resultImage)
    }

    func drawBlur() {

        guard let image = resultImage else {
            log.debug("No image to draw")
            return
        }

        guard let blurMask = createBlurMask(for: image) else {
            log.error("Failed to create blur mask")
            displayMessage("Error", "Failed to apply blur effect")
            return
        }

        let ciMaskImage = CIImage(image: blurMask)

        filter.setValue(ciMaskImage, forKey: "inputMask")

        guard
            let outputImage = filter.outputImage
            , let resultCIImage = ciContext.createCGImage(outputImage, from: CGRect(origin: .zero, size: image.size))
        else {
            log.error("Failed to create blurred image")
            displayMessage("Error", "Failed to apply blur effect")
            return
        }

        resultImageView.image = UIImage(cgImage: resultCIImage)
    }


    func createBlurMask(for image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)

        let blurFrame = blurEffectView.frame
        let imageFrame = resultImageView.imageFrame()
        let scale = resultImageView.imageScale()

        let scaledBlurFrame = CGRect(x: (blurFrame.minX - imageFrame.minX) / scale, y: (blurFrame.minY - imageFrame.minY) / scale, width: blurFrame.width / scale, height: blurFrame.height / scale)

        context.addEllipse(in: scaledBlurFrame)
        context.drawPath(using: .fill)

        let blurMask = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return blurMask
    }

    func createGestureRecognizer() -> UIPanGestureRecognizer {
        return UIPanGestureRecognizer(target: self, action: #selector(blurPan))
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
