//
//  GZETestViewController.swift
//  Gooze
//
//  Created by Yussel on 11/24/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZETestViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var doubleView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var gzeDoubleView: GZEDoubleCtrlView!

    let border = CALayer()

    var activeField: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        textField.delegate = self
        doubleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GZETestViewController.viewTapped)))

        userLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GZETestViewController.labelTapped)))

        backLabel.textColor = UIColor.clear


        let width = CGFloat(1.0)

        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: self.backLabel.frame.height - width, width: self.backLabel.frame.width + 50, height: 1)

        border.borderWidth = width
        backLabel.layer.addSublayer(border)
        backLabel.layer.masksToBounds = true

        // backLabel.reactive.text <~ textField.reactive.continuousTextValues

        textField.reactive.continuousTextValues.observeValues { [unowned self] in

            self.backLabel.text = $0


            self.border.frame = CGRect(x: 0, y: self.backLabel.frame.height - width, width: self.backLabel.frame.width + 50, height: 1)
        }

        registerForKeyboarNotifications(
            observer: self,
            didShowSelector: #selector(GZETestViewController.keyboardShown(notification:)),
            willHideSelector: #selector(GZETestViewController.keyboardWillHide(notification:))
        )

        let text = UITextField()
        let label = UILabel()

        //text.textColor = .white
       // text.font = UIFont(name: "HelveticaNeue", size: 17)

        //label.textColor = .white
        //label.textAlignment = .center
        //label.font = UIFont(name: "HelveticaNeue", size: 17)
        label.text = "USUARIO"

       label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GZETestViewController.labelTapped)))


        let button = UIButton()
        button.setTitle("BUTTON", for: .normal)
        button.addTarget(self, action: #selector(GZETestViewController.buttonTapped(_:)), for: .touchUpInside)

        gzeDoubleView.topCtrlView = text
        gzeDoubleView.bottomCtrlView = label

        gzeDoubleView.separatorWidth = 200

        gzeDoubleView.topViewTappedHandler = { _ in
            text.becomeFirstResponder()
        }

        gzeDoubleView.bottomViewTappedHandler = {[unowned self] _ in
            button.sendActions(for: .touchUpInside)
            self.gzeDoubleView.bottomCtrlView = button
        }
    }

    func buttonTapped(_ sender: UIButton){
        log.debug(sender.title(for: .normal) as Any)
        UIView.animate(withDuration: 0.3, animations: {
            sender.alpha = 0
            sender.alpha = 1
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func viewTapped() {
        log.debug("view tapped")
        textField.becomeFirstResponder()
    }

    func labelTapped() {
        log.debug("label tapped")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        log.debug("Next")
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func keyboardShown(notification: Notification) {
        addKeyboardInsetAndScroll(scrollView: scrollView, activeField: activeField, notification: notification)
    }

    func keyboardWillHide(notification: Notification) {
        removeKeyboardInset(scrollView: scrollView)
    }

}
