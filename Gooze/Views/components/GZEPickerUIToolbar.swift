//
//  GZEPickerUIToolbar.swift
//  Gooze
//
//  Created by Yussel on 2/23/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEPickerUIToolbar: UIToolbar {

    enum ButtonTitle: String {
        case nextButtonTitle = "vm.pickerToolbar.nextButton.title"
        case doneButtonTitle = "vm.pickerToolbar.doneButton.title"
        case closeButtonTitle = "vm.pickerToolbar.closeButton.title"

        var localized: String {
            return self.rawValue.localized()
        }
    }

    var rightButtonTitle = ButtonTitle.nextButtonTitle {
        didSet {
            doneButton.title = rightButtonTitle.localized
        }
    }

    var onDone: ((UIBarButtonItem) -> ())?
    var onClose: ((UIBarButtonItem) -> ())?

    let closeButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: #selector(closeButtonTapped(_:)))
    let doneButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneButtonTapped(_:)))

    init() {
        super.init(frame: CGRect.zero)

        log.debug("\(self) init")
        initProperties()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        log.debug("\(self) init")
        initProperties()
    }

    private func initProperties() {
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        closeButton.title = ButtonTitle.closeButtonTitle.localized
        doneButton.title = ButtonTitle.nextButtonTitle.localized

        self.setItems([closeButton, spaceButton, doneButton], animated: false)

        self.barStyle = UIBarStyle.default
        self.isTranslucent = true
        self.sizeToFit()
        self.isUserInteractionEnabled = true
    }

    func closeButtonTapped(_ sender: UIBarButtonItem) {
        onClose?(sender)
    }

    func doneButtonTapped(_ sender: UIBarButtonItem) {
        onDone?(sender)
    }

    // MARK: Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
