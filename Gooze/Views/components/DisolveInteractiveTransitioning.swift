//
//  DisolveInteractiveTransitioning.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 6/20/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class DisolveInteractiveTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        toVC?.view.alpha = 0.0
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        transitionContext.containerView.addSubview(fromVC!.view)
        transitionContext.containerView.addSubview(toVC!.view)

        UIView.animate(withDuration: 0.5, animations: {
            toVC?.view.alpha = 1.0
        }) { (completed) in
            fromVC?.view.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
