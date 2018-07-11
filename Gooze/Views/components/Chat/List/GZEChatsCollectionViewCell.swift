//
//  GZEChatsCollectionViewCell.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/22/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEChatsCollectionViewCell: UICollectionViewCell {
    var model: GZEChatCellModelDates? {
        didSet {
            if let model = self.model {
                self.setChatModel(model)
            } else {
                self.clear()
            }
        }
    }

    var user: GZEUserConvertible? {
        set{
            self.photoView.balloon.setUser(newValue)
            self.photoView.balloon.setVisible(true)
        }
        get {
            return self.photoView.balloon.userConvertible
        }
    }
    var title: String? {
        set{
            self.previewView.title.text = newValue
        }
        get {
            return self.previewView.title.text
        }
    }
    var preview: String? {
        set{
            self.previewView.preview.text = newValue
        }
        get {
            return self.previewView.preview.text
        }
    }
    var unreadMessages: Int = 0 {
        didSet {
            self.photoView.pp_addBadge(withNumber: self.unreadMessages)
        }
    }

    var onClose: HandlerBlock<GZEChatsCollectionViewCell>?
    var onTap: HandlerBlock<GZEChatsCollectionViewCell>?

    var isBlocked = false {
        didSet{
            let hiddenAlpha: CGFloat = 0.2
            let shownAlpha: CGFloat = 1
            if self.isBlocked {
                self.photoView.alpha = hiddenAlpha
                self.openView.alpha = hiddenAlpha
                self.previewView.title.alpha = hiddenAlpha
                self.previewView.preview.alpha = hiddenAlpha
                self.previewView.lockButton.alpha = shownAlpha
            } else {
                self.photoView.alpha = shownAlpha
                self.openView.alpha = shownAlpha
                self.previewView.title.alpha = shownAlpha
                self.previewView.preview.alpha = shownAlpha
                self.previewView.lockButton.alpha = hiddenAlpha
            }
        }
    }

    let stackView = UIStackView()
    let closeView = GZEChatsCloseView()
    let photoView = GZEChatsPhotoView()
    let previewView = GZEChatsPreviewView()
    let openView = GZEChatsOpenView()

    let photoViewWidth: CGFloat = 80

    var borders = [CALayer]()

    // MARK: init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    init() {
        super.init(frame: CGRect.zero)
        initialize()
    }


    // MARK: private methods
    private func initialize() {
        self.stackView.axis = .horizontal
        self.stackView.alignment = .fill
        self.stackView.distribution = .fill
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        self.addGestureRecognizer(swipeLeft)
        self.addGestureRecognizer(swipeRight)

        self.photoView.pp_addBadge(withNumber: 0)
        self.photoView.pp_moveBadgeWith(x: photoViewWidth - 5, y: 7)
        self.photoView.pp_setBadgeLabelAttributes{label in
            label?.backgroundColor = GZEConstants.Color.mainGreen
            label?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
        }

        self.closeView.onTap = handleClose
        self.photoView.onTap = handleTap
        self.previewView.onTap = handleTap
        self.openView.onTap = handleTap

        self.closeView.isHidden = true

        self.stackView.addArrangedSubview(self.closeView)
        self.stackView.addArrangedSubview(self.photoView)
        self.stackView.addArrangedSubview(self.previewView)
        self.stackView.addArrangedSubview(self.openView)

        self.addSubview(self.stackView)

        // Constraints
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.closeView.translatesAutoresizingMaskIntoConstraints = false
        self.photoView.translatesAutoresizingMaskIntoConstraints = false
        self.openView.translatesAutoresizingMaskIntoConstraints = false

        self.topAnchor.constraint(equalTo: self.stackView.topAnchor, constant: -5).isActive = true
        self.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 5).isActive = true
        self.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor).isActive = true

        self.closeView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        self.photoView.widthAnchor.constraint(equalToConstant: photoViewWidth).isActive = true
        self.openView.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }

    func setChatModel(_ model: GZEChatCellModelDates) {
        self.user = model.user
        self.title = model.title
        self.preview = model.preview
        self.unreadMessages = model.unreadMessages
        self.onClose = model.onClose
        self.onTap = model.onTap
        self.isBlocked = model.isBlocked
        self.showClose(show: model.isCloseShown)
    }

    func clear() {
        self.user = nil
        self.title = nil
        self.preview = nil
        self.unreadMessages = 0
        self.onClose = nil
        self.onTap = nil
        self.isBlocked = false
        self.showClose(show: false)
    }

    func handleClose() {
        self.onClose?(self)
    }

    func handleTap() {
        if !self.isBlocked {
            self.onTap?(self)
        }
    }

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
                self.openView.isHidden = true
            }
        } else {
            if self.openView.isHidden {
                self.closeView.isHidden = true
                self.openView.isHidden = false
            }
        }
    }

    func handleSwipe(_ gestureRecognizer : UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            log.debug("swipe gesture view: \(String(describing: gestureRecognizer.view))")
            log.debug("direction: \(gestureRecognizer.direction)")
            if let view = gestureRecognizer.view as? GZEChatsCollectionViewCell {
                if gestureRecognizer.direction == .right {
                    view.showClose(show: true, animate: true)
                } else if gestureRecognizer.direction == .left {
                    view.showClose(show: false, animate: true)
                }
            }
        }
    }
}
