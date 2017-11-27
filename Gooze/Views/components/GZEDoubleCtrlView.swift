//
//  GZEDoubleCtrlView.swift
//  Gooze
//
//  Created by Yussel on 11/24/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class GZEDoubleCtrlView: UIView {

    let topView = UIView()
    let bottomView = UIView()
    let separatorView = UIView()
    let underlineLabel = UILabel()

    var topCtrlView: UIView? {
        willSet(newCtrlView) { topCtrlViewWillSet(newCtrlView) }
    }
    var bottomCtrlView: UIView? {
        willSet(newCtrlView) { bottomCtrlViewWillSet(newCtrlView) }
    }

    var underlineLabelObserver: Disposable?

    var separatorWidthConstraint: NSLayoutConstraint
    var separatorWidth: CGFloat = 100 {
        didSet {
            separatorWidthConstraint.constant = separatorWidth
            layoutIfNeeded()
        }
    }

    var font = UIFont(name: "HelveticaNeue", size: 17)!
    var animationsDuration = 0.3

    var topViewTappedHandler: ((UITapGestureRecognizer) -> ())?
    var bottomViewTappedHandler: ((UITapGestureRecognizer) -> ())?

    required init?(coder aDecoder: NSCoder) {
        separatorWidthConstraint = separatorView.widthAnchor.constraint(equalToConstant: separatorWidth)

        super.init(coder: aDecoder)

        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.isUserInteractionEnabled = true
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GZEDoubleCtrlView.viewTapped(sender:))))



        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.isUserInteractionEnabled = true
        bottomView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GZEDoubleCtrlView.viewTapped(sender:))))

        separatorView.backgroundColor = .white
        separatorView.translatesAutoresizingMaskIntoConstraints = false

        underlineLabel.font = font
        underlineLabel.textColor = UIColor.clear
        underlineLabel.textAlignment = .center
        underlineLabel.layer.borderColor = UIColor.white.cgColor
        underlineLabel.layer.borderWidth = 1
        underlineLabel.translatesAutoresizingMaskIntoConstraints = false
        underlineLabel.heightAnchor.constraint(equalToConstant: 1).isActive = true

        addSubview(topView)
        addSubview(bottomView)
        addSubview(separatorView)

        setConstraints()
    }

    func setConstraints() {
        // Constraints: Second element is a weak reference, so if a element could be disposed assign it as second element of the constraint

        // self
        leadingAnchor.constraint(equalTo: topView.leadingAnchor).isActive = true
        leadingAnchor.constraint(equalTo: bottomView.leadingAnchor).isActive = true

        trailingAnchor.constraint(equalTo: topView.trailingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: bottomView.trailingAnchor).isActive = true

        topAnchor.constraint(equalTo: topView.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: bottomView.bottomAnchor).isActive = true

        centerXAnchor.constraint(equalTo: separatorView.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: separatorView.centerYAnchor).isActive = true

        // topView
        topView.bottomAnchor.constraint(equalTo: separatorView.topAnchor, constant: 1).isActive = true

        // bottomView
        bottomView.topAnchor.constraint(equalTo: separatorView.bottomAnchor).isActive = true

        // separatorView
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separatorWidthConstraint.isActive = true
    }

    func topCtrlViewWillSet (_ newCtrlView: UIView?) {

        if newCtrlView == self.topCtrlView { return }

        if let oldCtrlView = self.topCtrlView {
            // oldCtrlView.removeFromSuperview()
            removeAnimated(oldCtrlView)
        }

        if let topCtrlView = newCtrlView {

            topCtrlView.translatesAutoresizingMaskIntoConstraints = false
            topCtrlView.bounds.size.height = 21

            // topView.addSubview(topCtrlView)
            addAnimated(topCtrlView, superView: topView)

            topView.leadingAnchor.constraint(equalTo: topCtrlView.leadingAnchor).isActive = true
            topView.trailingAnchor.constraint(equalTo: topCtrlView.trailingAnchor).isActive = true
            topView.bottomAnchor.constraint(equalTo: topCtrlView.bottomAnchor, constant: 9).isActive = true

            if let textDisplay = topCtrlView as? TextDisplay {
                textDisplay.setAlignment(.center)
                textDisplay.setColor(.white)
                textDisplay.setTextFont(font)
            }

            if let topCtrlText = topCtrlView as? UITextField {

                underlineLabelObserver = underlineLabel.reactive.text <~ topCtrlText.reactive.continuousTextValues

                topView.addSubview(underlineLabel)

                topView.bottomAnchor.constraint(equalTo: underlineLabel.bottomAnchor).isActive = true
                topView.centerXAnchor.constraint(equalTo: underlineLabel.centerXAnchor).isActive = true

            } else {

                underlineLabel.removeFromSuperview()
                underlineLabelObserver?.dispose()
            }
        }
    }

    func bottomCtrlViewWillSet (_ newCtrlView: UIView?) {
        if newCtrlView == self.bottomCtrlView { return }

        if let oldCtrlView = self.bottomCtrlView {
            // oldCtrlView.removeFromSuperview()
            removeAnimated(oldCtrlView)
        }

        if let bottomCtrlView = newCtrlView {

            bottomCtrlView.translatesAutoresizingMaskIntoConstraints = false

            // bottomView.addSubview(bottomCtrlView)
            addAnimated(bottomCtrlView, superView: bottomView)

            bottomView.leadingAnchor.constraint(equalTo: bottomCtrlView.leadingAnchor).isActive = true
            bottomView.trailingAnchor.constraint(equalTo: bottomCtrlView.trailingAnchor).isActive = true
            bottomView.topAnchor.constraint(equalTo: bottomCtrlView.topAnchor, constant: -8).isActive = true
            bottomCtrlView.heightAnchor.constraint(equalToConstant: 21).isActive = true

            if let textDisplay = bottomCtrlView as? TextDisplay {
                textDisplay.setAlignment(.center)
                textDisplay.setColor(.white)
                textDisplay.setTextFont(font)
            }
        }
    }

    func viewTapped(sender: UITapGestureRecognizer) {
        switch sender.view {
        case .some(topView):
            log.debug("top view tapped")
            topViewTappedHandler?(sender)
        case .some(bottomView):
            log.debug("bottom view tapped")
            bottomViewTappedHandler?(sender)
        default:
            log.debug("invalid view tapped")
        }
    }

    func removeAnimated(_ view: UIView) {
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: animationsDuration, animations: {
            view.alpha = 0
        }) { _ in
            view.removeFromSuperview()
        }
    }

    func addAnimated(_ view: UIView, superView: UIView) {
        view.alpha = 0
        superView.addSubview(view)
        UIView.animate(withDuration: animationsDuration) {
            view.alpha = 1
        }
    }
}
