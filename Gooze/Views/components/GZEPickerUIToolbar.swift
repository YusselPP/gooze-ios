//
//  GZEPickerUIToolbar.swift
//  Gooze
//
//  Created by Yussel on 2/23/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEPickerUIToolbar: UIToolbar {

    let closeButtonTitle = "vm.pickerToolbar.closeButton.title".localized()

    var doneButtonTitle = "vm.pickerToolbar.doneButton.title".localized() {
        didSet {
            doneButton.title = doneButtonTitle
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
        closeButton.title = closeButtonTitle
        doneButton.title = doneButtonTitle

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
