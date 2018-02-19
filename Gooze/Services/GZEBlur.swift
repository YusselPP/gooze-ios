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

    let ciContext = CIContext(options: nil)
    let filter = CIFilter(name: "CIMaskedVariableBlur")!
    let error = MutableProperty<String?>(nil)

    var resultImageView: UIImageView
    var blurEffectView: UIView


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



    init(image: UIImage, blurEffectView: UIView, resultImageView: UIImageView) {

        self.image = image
        self.blurEffectView = blurEffectView
        self.resultImageView = resultImageView

        log.debug("\(self) init")

        imageDidSet()
        radiusDidSet()
    }

    func apply() {
        resultImage = resultImageView.image
    }

    func revert() {
        resultImage = image
    }

    func draw() {

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

    private func createMask(for image: UIImage) -> UIImage? {
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

    private func errorMessage(_ msg: String) {
        log.error(msg)
        error.value = msg
    }

    // MARK: - Setters
    func imageDidSet() {
        log.debug("image did set \(String(describing: image))")
        resultImage = image
    }

    func resultImageDidSet() {
        log.debug("result image did set \(String(describing: resultImage))")
        var ciImage: CIImage?
        if let resultImage = self.resultImage {
            ciImage = CIImage(image: resultImage)
        }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        draw()
    }

    func radiusDidSet() {
        log.debug("radius did set \(String(describing: radius))")
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        draw()
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
