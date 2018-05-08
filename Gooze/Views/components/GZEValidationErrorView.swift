//
//  GZEValidationErrorView.swift
//  Gooze
//
//  Created by Yussel on 3/24/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEValidationErrorView: UIView {

    open var text: String = "" {
        didSet {
            self.textLabel.text = self.text
        }
    }

    open var onTapped: (() -> ())?
    open var onDismiss: (() -> ())?
    
    private var shown = false
    private var isShowing = false
    private var isDismissing = false
    private var dismissWhenShown = false
    private var dismissWhenShownCompletion: (() -> Void)?
    private var showWhenDismessed = false
    private var showWhenDismessedCompletion: (() -> Void)?
    
    private let discardButton = DismissView()

    private let textView = UIView()
    let textLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    open func show(completion onComplete: (() -> Void)? = nil) {
        
        if self.isShowing || shown {
            return
        }
        
        if self.isDismissing {
            self.showWhenDismessed = true
            self.showWhenDismessedCompletion = onComplete
            return
        }
        
        self.isShowing = true
        
        UIView.animate(withDuration: 0.5, animations: {[weak self] in
            self?.alpha = 1
        }, completion: {[weak self] _ in
            guard let this = self else {
                log.error("self disposed")
                return
            }
            
            this.isShowing = false
            this.shown = true
            onComplete?()
            
            if this.dismissWhenShown {
                this.dismissWhenShown = false
                this.dismiss(completion: onComplete)
            }
        })
    }

    open func dismiss(completion onComplete: (() -> Void)? = nil) {
        
        if self.isDismissing || !shown {
            return
        }
        
        if self.isShowing {
            self.dismissWhenShown = true
            self.dismissWhenShownCompletion = onComplete
            return
        }
        
        self.onDismiss?()
        self.isDismissing = true
        
        UIView.animate(withDuration: 0.5, animations: {[weak self] in
            self?.alpha = 0
        }, completion: {[weak self] _ in
            guard let this = self else {
                log.error("self disposed")
                return
            }
            
            this.isDismissing = false
            this.shown = false
            onComplete?()
            
            if this.showWhenDismessed {
                this.showWhenDismessed = false
                this.show(completion: onComplete)
            }
        })
    }
    
    open func handleTapped() {
        self.onTapped?()
    }
    
    func handleDismiss() {
        self.dismiss()
    }

    private func initialize() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textView.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false


        self.alpha = 0
        self.backgroundColor = GZEConstants.Color.validationErrorViewBg
        self.discardButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapped)))


        self.textLabel.font = GZEConstants.Font.main
        self.textLabel.textAlignment = .center
        self.textLabel.numberOfLines = 3
        self.textLabel.isUserInteractionEnabled = true
        self.textView.isUserInteractionEnabled = true
        self.textView.addSubview(textLabel)


        self.addSubview(textView)
        self.addSubview(discardButton)


        // Constraints
        self.discardButton.widthAnchor.constraint(equalToConstant: 60).isActive = true

        // self.textView.centerXAnchor.constraint(equalTo: textLabel.centerXAnchor).isActive = true
        self.textLabel.leadingAnchor.constraint(equalTo: discardButton.trailingAnchor).isActive = true
        self.textLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -50).isActive = true
        self.textView.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor).isActive = true

        self.leadingAnchor.constraint(equalTo: self.discardButton.leadingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.textView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.textView.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: self.discardButton.topAnchor).isActive = true
        self.topAnchor.constraint(equalTo: self.textView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.discardButton.bottomAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.textView.bottomAnchor).isActive = true
    }
}

