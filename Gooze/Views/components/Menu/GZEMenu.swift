//
//  GZEMenu.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 5/17/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEMenu: NSObject {

    var animationsDuration: TimeInterval = 0.3
    var isScrollTopOnCloseEnabled = true

    let buttonView = GZEMenuButton()
    let view = GZEMenuView()

    var menuContainer = UIView() {
        didSet {
            self.view.removeFromSuperview()
            self.menuContainer.addSubview(self.view)

            self.menuContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            self.menuContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            self.menuContainer.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            self.menuContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
    }

    var isOpen: Bool {
        return !(!self.state) == .open
    }


    // MARK: - init
    override init() {
        super.init()

        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.alpha = 0

        self.buttonView.onButtonTapped = {[weak self] _ in
            self?.toggle(animated: true)
        }
        self.view.onDismiss = {[weak self] in
            self?.close(animated: true)
        }
    }


    func open(animated: Bool, completion: CompletionBlock? = nil) {
        self.setState(.open, animated: animated, completion: completion)
    }

    func close(animated: Bool, completion: CompletionBlock? = nil) {
        self.setState(.closed, animated: animated){[weak self] in
            guard let this = self else {return}
            if this.isScrollTopOnCloseEnabled {
                this.view.scrollView.contentOffset.y = 0
            }
            completion?()
        }
    }

    func toggle(animated: Bool, completion: CompletionBlock? = nil) {
        if !(!self.state) == .open {
            self.close(animated: animated, completion: completion)
        } else {
            self.open(animated: animated, completion: completion)
        }
    }


    // MARK: - private
    // MARK: - State transition
    private enum State {
        case open
        case opening
        case closed
        case closing

        static prefix func !(state: State) -> State {
            switch state {
            case .closed, .closing:
                return .open
            case .open, .opening:
                return .closed
            }
        }

        func isTransition() -> Bool {
            return self == .closing || self == .opening
        }
    }

    private var pendingState: (State, Bool, CompletionBlock?)?
    private var state: State = .closed


    private func setState(_ newState: State, animated: Bool, completion: CompletionBlock? = nil) {
        let normalizedState = !(!newState)

        log.debug("Setting new state.. Current state: \(self.state), New state: \(normalizedState)")

        if self.state == normalizedState {
            log.debug("Trying to set an equal state, ignoring transition.")
            return
        }

        if self.state.isTransition() {
            log.debug("A transition is on going, ignoring transition")
            // log.debug("A transition is on going, setting pending state")
            // self.pendingState = (normalizedState, animated, completion)
            return
        }

        self.state = normalizedState == .open ? .opening : .closing

        if animated {
            UIView.animate(withDuration: animationsDuration, animations: {

                self.transformView(normalizedState)

            }, completion: {[weak self] _ in
                guard let this = self else {
                    completion?()
                    return
                }

                this.completeStateTransition(normalizedState, completion: completion)
            })
        } else {
            self.transformView(normalizedState)

            self.completeStateTransition(normalizedState, completion: completion)
        }
    }

    private func transformView(_ state: State) {
        if state == .open {
            self.view.alpha = 1
        } else {
            self.view.alpha = 0
        }
    }

    private func completeStateTransition(_ state: State, completion: CompletionBlock?) {
        log.debug("Completing state transition.. Current state: \(self.state)")
        self.state = state
        completion?()

        if let (newState, animated, completion) = self.pendingState {
            log.debug("Setting pending state: \(newState)")
            self.pendingState = nil
            self.setState(newState, animated: animated, completion: completion)
        }
        log.debug("State transition completed. Current state: \(self.state)")
    }

    

}
