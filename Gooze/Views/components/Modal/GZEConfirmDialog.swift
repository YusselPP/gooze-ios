//
//  GZEConfirmDialog.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 10/16/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEConfirmDialog: UIView, Modal {
    var backgroundView = UIView()
    var dialogView = UIView()
    var centerYConstraint: NSLayoutConstraint?


    convenience init(title:String) {
        self.init(frame: UIScreen.main.bounds)
        initialize(title: title)

    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func initialize(title:String){
        dialogView.clipsToBounds = true

        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.6
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView)))
        addSubview(backgroundView)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 10
        dialogView.addSubview(titleLabel)

        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor.groupTableViewBackground
        dialogView.addSubview(separatorLineView)

        let verticalSeparatorLineView = UIView()
        verticalSeparatorLineView.backgroundColor = UIColor.groupTableViewBackground


        let buttonsStack = UIStackView()
        buttonsStack.axis = .horizontal
        buttonsStack.alignment = .fill
        buttonsStack.distribution = .fillProportionally
        dialogView.addSubview(buttonsStack)


        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("Cancelar", for: .normal)
        cancelButton.setTitleColor(.black, for: .normal)
        cancelButton.setTitleColor(.gray, for: .highlighted)
        cancelButton.setTitleColor(.gray, for: .disabled)
        buttonsStack.addArrangedSubview(cancelButton)


        buttonsStack.addArrangedSubview(verticalSeparatorLineView)

        let acceptButton = UIButton(type: .custom)
        acceptButton.setTitle("Aceptar", for: .normal)
        acceptButton.setTitleColor(.black, for: .normal)
        acceptButton.setTitleColor(.gray, for: .highlighted)
        acceptButton.setTitleColor(.gray, for: .disabled)
        buttonsStack.addArrangedSubview(acceptButton)


        dialogView.frame.origin = CGPoint(x: 30, y: frame.height)
        dialogView.backgroundColor = UIColor(white: 0.7, alpha: 1)
        dialogView.layer.cornerRadius = 6
        addSubview(dialogView)


        // CONSTRAINTS
        // label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dialogView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -16).isActive = true
        dialogView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -16).isActive = true
        dialogView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: separatorLineView.topAnchor, constant: -16).isActive = true

        // separator
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        dialogView.leadingAnchor.constraint(equalTo: separatorLineView.leadingAnchor).isActive = true
        dialogView.trailingAnchor.constraint(equalTo: separatorLineView.trailingAnchor).isActive = true

        verticalSeparatorLineView.translatesAutoresizingMaskIntoConstraints = false
        verticalSeparatorLineView.widthAnchor.constraint(equalToConstant: 1).isActive = true

        // button stack
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.topAnchor.constraint(equalTo: separatorLineView.bottomAnchor).isActive = true
        dialogView.bottomAnchor.constraint(equalTo: buttonsStack.bottomAnchor).isActive = true
        dialogView.leadingAnchor.constraint(equalTo: buttonsStack.leadingAnchor).isActive = true
        dialogView.trailingAnchor.constraint(equalTo: buttonsStack.trailingAnchor).isActive = true


        // dialog view
        dialogView.translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: dialogView.leadingAnchor, constant: -30).isActive = true
        trailingAnchor.constraint(equalTo: dialogView.trailingAnchor, constant: 30).isActive = true
        centerYConstraint = centerYAnchor.constraint(equalTo: dialogView.centerYAnchor, constant: frame.height)
        centerYConstraint?.isActive = true

    }

    func didTappedOnBackgroundView(){
        dismiss(animated: true)
    }
}
