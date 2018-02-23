//
//  GZEProfilePageViewController.swift
//  Gooze
//
//  Created by Yussel Paredes on 2/23/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import UIKit

class GZEProfilePageViewController: UIPageViewController {

    var viewModel: GZEProfileViewModel!


    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController("profileControllerId"),
                self.newViewController("ratingControllerId"),
                self.newViewController("galleryControllerId")]
    }()

    override func viewDidLoad() {
        log.debug("\(self) init")
        super.viewDidLoad()

        dataSource = self

        if let firstViewController = orderedViewControllers.first {

            if let profileVc = firstViewController as? GZEProfileViewController {
                log.debug("setting profile view controller view model")
                profileVc.viewModel = viewModel
            }

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
        return storyboard!.instantiateViewController(withIdentifier: identifier)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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

        let previousIndex = viewControllerIndex - 1

        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
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
    
}
