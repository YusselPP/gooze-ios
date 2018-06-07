//
//  GZEExitAppButton
//  Gooze
//
//  Created by Yussel on 11/29/17.
//  Copyright © 2017 Gooze. All rights reserved.
//

import UIKit

class GZEExitAppButton: GZENavButton {
    static let shared = GZEExitAppButton()

    weak var presenter: UIViewController?

    override init() {
        super.init()
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {
        button.frame = CGRect(x: 0.0, y: 0.0, width: 40, height: 40)
        button.setImage(#imageLiteral(resourceName: "exit-icon"), for: .normal)
        self.onButtonTapped = {[weak self] _ in
            if let presenter = self?.presenter {
                presenter.navigationController?.popToRootViewController(animated: false)
                GZEAuthService.shared.logout(presenter: presenter)
            } else {
                log.error("A presenter controller is required. Found nil")
            }
        }
    }
}
