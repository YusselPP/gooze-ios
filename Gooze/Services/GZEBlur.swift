//
//  GZEBlur.swift
//  Gooze
//
//  Created by Yussel on 2/18/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift

class GZEBlur {

    let error = MutableProperty<String?>(nil)

    var resultImageView: UIImageView
    var blurEffectView: UIView
    var scrollView: UIScrollView?

    var isEnabled: Bool { return _isEnabled }
    var isDirty = false

    var image: UIImage? {
        didSet {
            imageDidSet()
        }
    }

    var resultImage: UIImage? {
        didSet {
            resultImageDidSet()
        }
    }

    var radius: Float = 15 {
        didSet {
            radiusDidSet()
        }
    }

    // Private vars
    private let ciContext = CIContext(options: nil)
    private let filter = CIFilter(name: "CIMaskedVariableBlur")!
    private var _isEnabled = false


    init(image: UIImage, blurEffectView: UIView, resultImageView: UIImageView, scrollView: UIScrollView? = nil) {

        self.image = image
        self.blurEffectView = blurEffectView
        self.resultImageView = resultImageView
        self.scrollView = scrollView

        log.debug("\(self) init")

        imageDidSet()
        radiusDidSet()
    }

    func enable(){
        _isEnabled = true
        draw()
    }

    func disable() {
        //revert()
        resultImageView.image = resultImage
        _isEnabled = false
    }

    func apply() {
        if !isEnabled {
            return
        }
        resultImage = resultImageView.image
        isDirty = true
    }

    func revert() {
        resultImageView.image = image
        resultImage = image

        isDirty = false
    }

    func draw() {
        if !isEnabled {
            return
        }

        guard let image = resultImage else {
            log.debug("No image to draw")
            return
        }

        guard let blurMask = createMask(for: image) else {
            errorMessage("Failed to apply blur effect")
            return
        }

        let ciMaskImage = CIImage(image: blurMask)

        filter.setValue(ciMaskImage, forKey: "inputMask")

        guard
            let outputImage = filter.outputImage
            , let resultCIImage = ciContext.createCGImage(outputImage, from: CGRect(origin: .zero, size: image.size))
            else {
                errorMessage("Failed to apply blur effect")
                return
        }

        resultImageView.image = UIImage(cgImage: resultCIImage)
    }


    // Private methods
    private func createMask(for image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)

        let blurFrame = blurEffectView.frame
        let imageFrame = resultImageView.imageFrame()
        let scale = resultImageView.imageScale()
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0

        if let offset = scrollView?.contentOffset {
            xOffset = offset.x
            yOffset = offset.y
        }

        let scaledBlurFrame = CGRect(x: (blurFrame.minX - imageFrame.minX + xOffset) / scale, y: (blurFrame.minY - imageFrame.minY + yOffset) / scale, width: blurFrame.width / scale, height: blurFrame.height / scale)

        context.addEllipse(in: scaledBlurFrame)
        context.drawPath(using: .fill)

        let blurMask = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return blurMask
    }

    private func errorMessage(_ msg: String) {
        log.error(msg)
        error.value = msg
    }

    // MARK: - Setters
    private func imageDidSet() {
        log.debug("image did set \(String(describing: image))")
        resultImage = image
    }

    private func resultImageDidSet() {
        log.debug("result image did set \(String(describing: resultImage))")
        var ciImage: CIImage?
        if let resultImage = self.resultImage {
            ciImage = CIImage(image: resultImage)
        }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        draw()
    }

    private func radiusDidSet() {
        log.debug("radius did set \(String(describing: radius))")
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        draw()
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
