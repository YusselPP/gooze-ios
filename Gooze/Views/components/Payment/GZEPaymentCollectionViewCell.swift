//
//  GZEPaymentCollectionViewCell.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/14/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEPaymentCollectionViewCell: UICollectionViewCell {

    var swipeActionEnabled: Bool = false

    var model: GZEPaymentCellModel? {
        didSet {
            if let model = self.model {
                self.setCellModel(model)
            } else {
                self.clear()
            }
        }
    }

    var type: GZEPaymentCellModel.CellType = .element {
        didSet {
            switch self.type {
            case .add:
                self.iconView.isHidden = true
                self.topBorder.isHidden = false
                self.titleLabel.textAlignment = .center
            default:
                self.iconView.isHidden = false
                self.topBorder.isHidden = true
                self.titleLabel.textAlignment = .natural
            }
        }
    }

    var title: String? {
        set{
            self.titleLabel.text = newValue
        }
        get {
            return self.titleLabel.text
        }
    }

    var icon: UIView? {
        willSet {
            self.icon?.removeFromSuperview()
        }
        didSet{
            if let icon = self.icon {
                self.iconView.addSubview(icon)
                icon.translatesAutoresizingMaskIntoConstraints = false
                self.iconView.centerXAnchor.constraint(equalTo: icon.centerXAnchor).isActive = true
                self.iconView.centerYAnchor.constraint(equalTo: icon.centerYAnchor).isActive = true
                icon.widthAnchor.constraint(equalToConstant: 20).isActive = true
                icon.heightAnchor.constraint(equalToConstant: 20).isActive = true
            }
        }
    }

    var isSelection: Bool = false{
        didSet {
            self.check.isHidden = !self.isSelection
        }
    }

    var onTap: HandlerBlock<GZEPaymentCollectionViewCell>?
    var onClose: HandlerBlock<GZEPaymentCollectionViewCell>?

    let stackView = UIStackView()
    let iconView = UIView()
    let titleLabel = GZELabel()
    let check = GZELabel()
    let closeView = GZEChatsCloseView()

    let topBorder = UIView()

    // MARK: init
    required init?(coder aDecoder: NSCoder) {
        log.debug("init(coder aDecoder: NSCoder)")
        super.init(coder: aDecoder)
        initialize()
    }

    override init(frame: CGRect) {
        log.debug("init(frame: CGRect)")
        super.init(frame: frame)
        initialize()
    }

    init() {
        log.debug("init()")
        super.init(frame: CGRect.zero)
        initialize()
    }


    // MARK: private methods
    private func initialize() {

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        self.addGestureRecognizer(swipeLeft)
        self.addGestureRecognizer(swipeRight)


        self.closeView.button.setTitle("\u{f014}", for: .normal)
        self.closeView.button.setTextFont(GZEConstants.Font.mainAwesome.increase(by: 4))
        self.closeView.button.transform = .identity

        self.stackView.axis = .horizontal
        self.stackView.alignment = .center
        self.stackView.distribution = .fill
        self.stackView.spacing = 15

        self.titleLabel.setWhiteFontFormat(align: .natural)
        self.iconView.layer.cornerRadius = 5
        self.iconView.layer.masksToBounds = true
        self.iconView.backgroundColor = .lightGray

        self.check.setWhiteFontFormat(align: .left)
        self.check.font = GZEConstants.Font.mainAwesome
        self.check.text = "\u{f00c}   "

        self.closeView.isHidden = true
        self.closeView.onTap = handleClose

        self.topBorder.backgroundColor = .white

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))

        self.stackView.addArrangedSubview(self.closeView)
        self.stackView.addArrangedSubview(self.iconView)
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.check)

        self.addSubview(self.stackView)
        self.addSubview(self.topBorder)

        // Constraints
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.iconView.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.topBorder.translatesAutoresizingMaskIntoConstraints = false
        self.check.translatesAutoresizingMaskIntoConstraints = false
        self.closeView.translatesAutoresizingMaskIntoConstraints = false

        self.topAnchor.constraint(equalTo: self.stackView.topAnchor, constant: -4).isActive = true
        self.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 4).isActive = true
        self.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor).isActive = true

        self.iconView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.iconView.heightAnchor.constraint(equalToConstant: 28).isActive = true

        self.check.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.check.heightAnchor.constraint(equalToConstant: 28).isActive = true

        self.topAnchor.constraint(equalTo: self.topBorder.topAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.topBorder.trailingAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: self.topBorder.leadingAnchor).isActive = true
        self.topBorder.heightAnchor.constraint(equalToConstant: 1).isActive = true

        self.closeView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        self.closeView.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }

    func setCellModel(_ model: GZEPaymentCellModel) {
        self.type = model.type
        self.isSelection = model.isSelection
        self.title = model.title
        self.icon = model.icon
        self.onTap = model.onTap
        self.onClose = model.onClose
        self.swipeActionEnabled = model.swipeActionEnabled
        self.showClose(show: model.isCloseShown)
    }

    func clear() {
        self.type = .element
        self.isSelection = false
        self.title = nil
        self.icon = nil
        self.onTap = nil
        self.onClose = nil
        self.swipeActionEnabled = false
        self.showClose(show: false)
    }

    func handleClose() {
        self.onClose?(self)
    }

    func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        self.onTap?(self)
    }

    // Swipe action
    var isAnimating = false
    func showClose(show: Bool, animate: Bool) {
        guard !isAnimating else {
            log.debug("Animation in transition, ignoring showClose")
            return
        }

        if animate {
            isAnimating = true

            UIView.animate(withDuration: 0.3, animations: {[weak self] in
                self?.showClose(show: show)
            }) {[weak self] finished in
                log.debug("animations finished: \(finished)")
                if finished {
                    self?.isAnimating = false
                }
            }
        } else {
            self.showClose(show: show)
        }
    }

    private func showClose(show: Bool) {
        if show {
            if self.closeView.isHidden {
                self.closeView.isHidden = false
            }
        } else {
            if !self.closeView.isHidden {
                self.closeView.isHidden = true
            }
        }
    }

    func handleSwipe(_ gestureRecognizer : UISwipeGestureRecognizer) {
        guard swipeActionEnabled else { return }
        if gestureRecognizer.state == .ended {
            log.debug("swipe gesture view: \(String(describing: gestureRecognizer.view))")
            log.debug("direction: \(gestureRecognizer.direction)")
            if let view = gestureRecognizer.view as? GZEPaymentCollectionViewCell {
                if gestureRecognizer.direction == .right {
                    view.showClose(show: true, animate: true)
                } else if gestureRecognizer.direction == .left {
                    view.showClose(show: false, animate: true)
                }
            }
        }
    }
}
