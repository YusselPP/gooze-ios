//
//  GZEMenuMain.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/19/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

class GZEMenuMain {

    static let shared = GZEMenuMain()

    let menuItemTitleProfile = "menu.item.title.profile".localized().uppercased()
    let menuItemTitleBeGooze = "menu.item.title.beGooze".localized().uppercased()
    let menuItemTitleSearchGooze = "menu.item.title.searchGooze".localized().uppercased()
    let menuItemTitleChats = "menu.item.title.chats".localized().uppercased()
    let menuItemTitleHistory = "menu.item.title.history".localized().uppercased()
    let menuItemTitlePayment = "menu.item.title.payment".localized().uppercased()
    let menuItemTitleCoupons = "menu.item.title.coupons".localized().uppercased()
    let menuItemTitleTransactions = "menu.item.title.transactions".localized().uppercased()
    let menuItemTitleInvite = "menu.item.title.invite".localized().uppercased()
    let menuItemTitleTips = "menu.item.title.tips".localized().uppercased()
    let menuItemTitleHelp = "menu.item.title.help".localized().uppercased()
    let menuItemTitleConfiguration = "menu.item.title.configuration".localized().uppercased()
    let menuItemTitleLogout = "menu.item.title.logout".localized().uppercased()

    let menu = GZEMenu()
    var navButton: GZEMenuButton {
        get {
            return self.menu.buttonView
        }
    }
    var containerView: UIView {
        set {
            self.menu.menuContainer = newValue
        }
        get {
            return self.menu.menuContainer
        }
    }

    var chatButton: GZEButton!

    var switchModeGoozeButton: GZEButton!

    weak var controller: GZEActivateGoozeViewController?

    lazy var logoutCocoaAction = {
        return self.createMenuAction(producer: SignalProducer{[weak self] in
            guard let controller = self?.controller else {return}
            //controller.navigationController?.popToRootViewController(animated: false)
            //GZEAuthService.shared.logout(presenter: controller)
            GZEExitAppButton.shared.button.sendActions(for: .touchUpInside)
        }).1
    }()

    lazy var logoutButton = {
        return self.createMenuItemButton(title: self.menuItemTitleLogout, action: self.logoutCocoaAction)
    }()

    init() {
        //let profileCocoaAction = CocoaAction<GZEButton>(Action<Void, Void, NoError>{SignalProducer.empty})

        let (_, profileCocoaAction) = createMenuAction(producer: SignalProducer{[weak self] in
            guard let controller = self?.controller else {return}
            controller.performSegue(withIdentifier: controller.segueToMyProfile, sender: nil)
        })

        let (_, switchModeCocoaAction) = createMenuAction(producer: SignalProducer{[weak self] in
            guard let controller = self?.controller else {return}

            if controller.scene == .activate {
                controller.scene = .search
            } else {
                controller.scene = .activate
            }
        })
        self.switchModeGoozeButton = createMenuItemButton(title: menuItemTitleSearchGooze, action: switchModeCocoaAction)

        let (_, chatCocoaAction) = createMenuAction(producer: SignalProducer{[weak self] in
            guard let controller = self?.controller else {return}
            controller.performSegue(withIdentifier: controller.segueToChats, sender: nil)
        })

        let (_, paymentCocoaAction) = createMenuAction(producer: SignalProducer{[weak self] in
            guard let controller = self?.controller else {return}
            controller.performSegue(withIdentifier: controller.segueToPayment, sender: nil)
        })

        let (_, tipsCocoaAction) = createMenuAction(producer: SignalProducer{[weak self] in
            guard let controller = self?.controller else {return}
            controller.performSegue(withIdentifier: controller.segueToTips, sender: nil)
        })

        chatButton = createMenuItemButton(title: menuItemTitleChats, action: chatCocoaAction, hasBadge: true)

        let menuItems = [
            createMenuItemButton(title: menuItemTitleProfile, action: profileCocoaAction),
            createMenuSeparator(),
            self.switchModeGoozeButton,
            createMenuSeparator(),
            chatButton,
            createMenuSeparator(),
            //createMenuItemButton(title: menuItemTitleHistory, action: profileCocoaAction),
            //createMenuSeparator(),
            createMenuItemButton(title: menuItemTitlePayment, action: paymentCocoaAction),
            createMenuSeparator(),
            //createMenuItemButton(title: menuItemTitleCoupons, action: profileCocoaAction),
            //createMenuSeparator(),
            //createMenuItemButton(title: menuItemTitleTransactions, action: profileCocoaAction),
            //createMenuSeparator(),
            //createMenuItemButton(title: menuItemTitleInvite, action: profileCocoaAction),
            //createMenuSeparator(),
            createMenuItemButton(title: menuItemTitleTips, action: tipsCocoaAction),
            createMenuSeparator(),
            //createMenuItemButton(title: menuItemTitleHelp, action: profileCocoaAction),
            //createMenuSeparator(),
            //createMenuItemButton(title: menuItemTitleConfiguration, action: profileCocoaAction),
            //createMenuSeparator(),
            logoutButton
        ]

        menuItems.forEach{
            menu.view.menuList.addArrangedSubview($0)
        }
    }

    func createMenuAction(producer: SignalProducer<Void, NoError> = SignalProducer.empty, onCloseMenu: CompletionBlock? = nil) -> (Action<(), Void, NoError>, CocoaAction<GZEButton>) {
        let action = Action{ () -> SignalProducer<Void, NoError> in
            log.debug("Menu action pressed")
            return producer
        }

        let cocoaAction = CocoaAction<GZEButton>(action) {[weak self] _ in
            self?.menu.close(animated: true) {
                onCloseMenu?()
            }
        }

        return (action, cocoaAction)
    }

    func createMenuItemButton(title: String, action: CocoaAction<GZEButton>, hasBadge: Bool = false) -> GZEButton {
        let button = GZEButton()
        button.setTitle(title, for: .normal)
        button.reactive.pressed = action
        button.backgroundColor = .clear
        button.widthConstraint.isActive = false
        button.heightConstraint.constant = 45

        if hasBadge {
            button.pp_addBadge(withNumber: 1)
            button.pp_moveBadgeWith(x: UIScreen.main.bounds.width / 2 + 30, y: 11)
            button.pp_setBadgeLabelAttributes{label in
                label?.backgroundColor = GZEConstants.Color.mainGreen
                label?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
            }
        }
        return button
    }

    func createMenuSeparator() -> UIView {
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .white

        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .clear
        separator.addSubview(line)
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

        separator.centerYAnchor.constraint(equalTo: line.centerYAnchor).isActive = true
        separator.centerXAnchor.constraint(equalTo: line.centerXAnchor).isActive = true
        separator.heightAnchor.constraint(equalTo: line.heightAnchor).isActive = true
        separator.widthAnchor.constraint(equalTo: line.widthAnchor, multiplier: 1.5).isActive = true

        return separator
    }
}
