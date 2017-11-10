//
//  GZEBlurViewController.swift
//  Gooze
//
//  Created by Yussel on 11/9/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

public typealias GZEBlurViewCompletion = (UIImage?) -> Void

class GZEBlurViewController: UIViewController {

    var image: UIImage
    var resultImage: UIImage?

    var onCompletion: GZEBlurViewCompletion?

    let filter = CIFilter(name: "CIMaskedVariableBlur")!
    let ciContext = CIContext(options: nil)

    let minimumBlurSize = CGSize(width: 60, height: 60)

    @IBOutlet weak var resultImageView: UIImageView!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    
    @IBOutlet weak var topLeftVButton: UIButton!
    @IBOutlet weak var topLeftHButton: UIButton!
    @IBOutlet weak var topRightVButton: UIButton!
    @IBOutlet weak var topRightHButton: UIButton!
    @IBOutlet weak var bottomLeftVButton: UIButton!
    @IBOutlet weak var bottomLeftHButton: UIButton!
    @IBOutlet weak var bottomRightVButton: UIButton!
    @IBOutlet weak var bottomRightHButton: UIButton!

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
        resultImageView.image = image

        blurEffectView.addGestureRecognizer(createGestureRecognizer())

        topLeftVButton.addGestureRecognizer(createGestureRecognizer())
        topLeftHButton.addGestureRecognizer(createGestureRecognizer())
        topRightVButton.addGestureRecognizer(createGestureRecognizer())
        topRightHButton.addGestureRecognizer(createGestureRecognizer())
        bottomLeftVButton.addGestureRecognizer(createGestureRecognizer())
        bottomLeftHButton.addGestureRecognizer(createGestureRecognizer())
        bottomRightVButton.addGestureRecognizer(createGestureRecognizer())
        bottomRightHButton.addGestureRecognizer(createGestureRecognizer())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func blurPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        if let button = gestureRecognizer.view as? UIButton {
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                let translation = gestureRecognizer.translation(in: self.view)

                let frame = blurEffectView.frame
                var newFrame: CGRect

                switch button {
                case topLeftHButton, topLeftVButton:
                    newFrame = CGRect(x: frame.origin.x + translation.x, y: frame.origin.y + translation.y, width: frame.size.width - translation.x, height: frame.size.height - translation.y)
                case topRightHButton, topRightVButton:
                    newFrame = CGRect(x: frame.origin.x, y: frame.origin.y + translation.y, width: frame.size.width + translation.x, height: frame.size.height - translation.y)
                case bottomLeftHButton, bottomLeftVButton:
                    newFrame = CGRect(x: frame.origin.x + translation.x, y: frame.origin.y, width: frame.size.width - translation.x, height: frame.size.height + translation.y)
                case bottomRightHButton, bottomRightVButton:
                    newFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width + translation.x, height: frame.size.height + translation.y)
                default:
                    newFrame = CGRect.zero
                }

                let minimumFrame = CGRect(x: newFrame.origin.x, y: newFrame.origin.y, width: max(newFrame.size.width, minimumBlurSize.width), height: max(newFrame.size.height, minimumBlurSize.height))
                blurEffectView.frame = minimumFrame

                gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
            }
        } else {
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                let translation = gestureRecognizer.translation(in: self.view)

                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x + translation.x, y: gestureRecognizer.view!.center.y + translation.y)
                gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
            }
        }
    }
    
    @IBAction func revertButtonTapped(_ sender: UIBarButtonItem) {
        resultImageView.image = image
    }

    @IBAction func applyButtonTapped(_ sender: UIBarButtonItem) {
        resultImageView.image = drawBlur(on: resultImageView.image)
    }

    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        close()
    }

    func close() {
        onCompletion?(resultImageView.image)
    }

    func drawBlur(on image: UIImage?) -> UIImage? {

        guard let image = resultImageView.image else {
            log.debug("No image to draw")
            return nil
        }

        guard let blurMask = createBlurMask(for: image) else {
            log.error("Failed to create blur mask")
            displayMessage("Error", "Failed to apply blur effect")
            return nil
        }

        let ciImage = CIImage(image: image)
        let ciMaskImage = CIImage(image: blurMask)

        filter.setDefaults()
        filter.setValue(20.0, forKey: kCIInputRadiusKey)
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(ciMaskImage, forKey: "inputMask")

        guard
            let outputImage = filter.outputImage,
            let resultCIImage = ciContext.createCGImage(outputImage, from: CGRect(origin: .zero, size: image.size))
        else {
            log.error("Failed to create blurred image")
            displayMessage("Error", "Failed to apply blur effect")
            return nil
        }

        return UIImage(cgImage: resultCIImage)
    }

    func createBlurMask(for image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)

        let imageFrame = resultImageView.imageFrame()
        let blurFrame = blurEffectView.frame
        let scale = resultImageView.imageScale()

        log.debug("image.size: \(image.size)")

        log.debug("image.frame: \(imageFrame)")
        log.debug("blur.frame: \(blurFrame)")


        let scaledBlurFrame = CGRect(x: (blurFrame.minX - imageFrame.minX) / scale, y: (blurFrame.minY - imageFrame.minY) / scale, width: blurFrame.width / scale, height: blurFrame.height / scale)

        log.debug("scaledBlur.frame: \(scaledBlurFrame)")

        context.addRect(scaledBlurFrame)
        context.drawPath(using: .fill)
        let blurMask = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return blurMask
    }

    func createGestureRecognizer() -> UIPanGestureRecognizer {
        return UIPanGestureRecognizer(target: self, action: #selector(blurPan))
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }
}
