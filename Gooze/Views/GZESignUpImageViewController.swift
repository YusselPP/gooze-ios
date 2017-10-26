//
//  GZESignUpImageViewController.swift
//  Gooze
//
//  Created by Yussel on 10/26/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

class GZESignUpImageViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurEffectView.frame = photoImageView.bounds

        self.view.addSubview(blurEffectView)


        //let dragInteraction = UIDragInteraction(delegate: self)
        //blurEffectView.addInteraction(dragInteraction)

        //let dropInteraction = UIDropInteraction(delegate: self)
        //blurEffectView.addInteraction(dropInteraction)

        //blurEffectView.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.

        let panGesture = UIPanGestureRecognizer(target: self, action:(#selector(GZESignUpImageViewController.blurPan(_:))))
        blurEffectView.addGestureRecognizer(panGesture)

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
