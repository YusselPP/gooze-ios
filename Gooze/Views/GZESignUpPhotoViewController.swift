//
//  GZESignUpPhotoViewController.swift
//  Gooze
//
//  Created by Yussel Paredes on 10/26/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZESignUpPhotoViewController: UIViewController {

    struct Blur {
        let show = MutableProperty<Bool>(false)
        let width = MutableProperty<Float>(20)
        let height = MutableProperty<Float>(20)
        let opacity = MutableProperty<Float>(1)
    }

    let blur = Blur()

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var alphaSlider: UISlider!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var widthSlider: UISlider!
    @IBOutlet weak var heightSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageContainerView.clipsToBounds = true

        blurEffectView.layer.cornerRadius = 20
        blurEffectView.layer.masksToBounds = true
        blurEffectView.alpha = CGFloat(alphaSlider.value)



        // blur.opacity <~ alphaSlider.reactive.values
        // blur.width <~ widthSlider.reactive.values
        // blur.height <~ heightSlider.reactive.values

        // blurEffectView.reactive.alpha <~ alphaSlider.reactive.values

        let panGesture = UIPanGestureRecognizer(target: self, action:(#selector(GZESignUpPhotoViewController.blurPan(_:))))
        blurEffectView.addGestureRecognizer(panGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        widthSlider.maximumValue = Float(photoImageView.bounds.width)
        heightSlider.maximumValue = Float(photoImageView.bounds.height)
        setViewSize(blurEffectView, CGFloat(50), CGFloat(50))
    }

    @IBAction func blurHeightSliderChanged(_ sender: UISlider) {
        setViewSize(blurEffectView, CGFloat(sender.value), blurEffectView.frame.height)
    }

    @IBAction func blurWidthSliderChanged(_ sender: UISlider) {
        setViewSize(blurEffectView, blurEffectView.frame.width, CGFloat(sender.value))
    }

    @IBAction func alphaSliderChanged(_ sender: UISlider) {
        blurEffectView.alpha = CGFloat(sender.value)
    }

    @IBAction func blurPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)

        sender.view!.center = CGPoint(x: sender.view!.center.x + translation.x, y: sender.view!.center.y + translation.y)
        
        sender.setTranslation(CGPoint.zero, in: self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setViewSize(_ view: UIView, _ width: CGFloat, _ heigth: CGFloat) -> Void {
        let frame = view.frame
        view.frame = CGRect(x: frame.minX, y: frame.minY, width: width, height: heigth)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
