//
//  GZEProfilePageViewController.swift
//  Gooze
//
//  Created by Yussel Paredes on 2/23/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEProfilePageViewController: UIPageViewController, GZEDismissVCDelegate, GZENextVCDelegate {

    let segueToChat = "segueToChat"
    let segueToPayments = "segueToPayments"
    let segueToRegisterPayPal = "segueToRegisterPayPal"

    var profileVm: GZEProfileUserInfoViewModel!
    var galleryVm: GZEGalleryViewModel!
    var ratingsVm: GZERatingsViewModel!

    var backButton = GZECloseUIBarButtonItem()

    private(set) lazy var orderedVms: [GZEProfileViewModel] = {
        return [
            self.profileVm,
            self.galleryVm,
            self.ratingsVm
        ]
    }()

    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController("profileControllerId"),
                self.newViewController("ratingControllerId"),
                self.newViewController("galleryControllerId")]
    }()

    override func viewDidLoad() {
        log.debug("\(self) init")
        super.viewDidLoad()

        backButton.onButtonTapped = {[weak self] _ in
            self?.previousController(animated: true)
        }
        navigationItem.setLeftBarButton(backButton, animated: false)
        self.navigationItem.rightBarButtonItem = GZEExitAppButton.shared

        self.view.backgroundColor = GZEConstants.Color.mainBackground

        dataSource = self

        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func newViewController(_ identifier: String) -> UIViewController {
        let vc = storyboard!.instantiateViewController(withIdentifier: identifier)

        if let profileVc = vc as? GZEProfileViewController {
            log.debug("setting profile view controller view model")
            profileVm.controller = self
            profileVc.viewModel = profileVm
            return profileVc
        }
        else if let galleryVc = vc as? GZEGalleryViewController {
            log.debug("setting gallery view controller view model")
            galleryVm.controller = self
            galleryVc.viewModel = galleryVm
            return galleryVc
        } else if let ratingsVc = vc as? GZERatingsViewController {
            log.debug("setting ratings view controller view model")
            ratingsVm.controller = self
            ratingsVc.viewModel = ratingsVm
            return ratingsVc
        }

        return vc
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == segueToChat {
            if
                let vc = segue.destination as? GZEChatViewController,
                let chatVm = sender as? GZEChatViewModel
            {
                vc.viewModel = chatVm
            } else {
                log.error("Unable to open GZEChatViewController, missing requiered parameters")
            }
        } else if segue.identifier == segueToPayments {
            preparePaymentSegue(segue.destination, vm: sender)
        } else if segue.identifier == segueToRegisterPayPal {
            GZERegisterPayPalViewController.prepareView(
                presenter: self,
                nextDelegate: self,
                viewController: segue.destination,
                vm: sender
            )
        }
    }

    func preparePaymentSegue(_ vc: UIViewController, vm: Any?) {
        if
            let vc = vc as? GZEPaymentMethodsViewController,
            let paymentVm = vm as? GZEPaymentMethodsViewModel
        {

            vc.viewModel = paymentVm
            vc.dismissDelegate = self

        } else {
            log.error("Unable to cast segue.destination as? GZEPaymentMethodsViewController")
        }
    }

    // MARK: Dismiss delegate
    func onDismissTapped(_ vc: UIViewController) {
        if vc.isKind(of: GZEPaymentMethodsViewController.self) {
            vc.previousController(animated: true)
        } else if vc.isKind(of: GZERegisterPayPalViewController.self) {
            vc.previousController(animated: true)
        }
    }

    func onNextTapped(_ vc: UIViewController) {
        if vc.isKind(of: GZERegisterPayPalViewController.self) {
            vc.previousController(animated: true)
        }
    }

    // MARK: - Deinitializers
    deinit {
        log.debug("\(self) disposed")
    }

}

// MARK: UIPageViewControllerDataSource

extension GZEProfilePageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }

        var previousIndex = viewControllerIndex - 1

        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        if previousIndex < 0 {
            previousIndex = orderedViewControllers.count - 1
        }

        guard orderedViewControllers.count > previousIndex else {
            return nil
        }

        return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return orderedViewControllers[nextIndex]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
