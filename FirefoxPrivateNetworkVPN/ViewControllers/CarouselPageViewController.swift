//
//  CarouselPageViewController
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

class CarouselPageViewController: UIPageViewController {

    /*init(root: LandingViewController) {
        self.initial = root
        super.init(transitionStyle: .scroll,
                   navigationOrientation: .horizontal,
                   options: .none)

        let carouselDataSource = CarouselPageViewDataSource(head: initial)
        delegate = carouselDataSource
        dataSource = carouselDataSource

        setViewControllers([initial], direction: .forward, animated: true, completion: nil)
    }*/

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let activityLogsViewController = LandingViewController()
        activityLogsViewController.setup(for: .activityLogs)
        let carouselDataSource = CarouselPageViewDataSource(head: activityLogsViewController)
        delegate = carouselDataSource
        dataSource = carouselDataSource

        setViewControllers([activityLogsViewController], direction: .forward, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.custom(.grey5)
//        navigationController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_close"), style: .plain, target: self, action: #selector(self.closeCarousel))
//        navigationController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Skip", style: .done, target: self, action: #selector(self.skipCarousel))
    }
}

extension CarouselPageViewDataSource: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

//    let head: LandingViewController

    init(head: LandingViewController) {
//        let activityLogsViewController = LandingViewController()
//        activityLogsViewController.setup(for: .activityLogs)

        self.head = head

        let encryptionViewController = LandingViewController()
        encryptionViewController.setup(for: .encryption)

        let countriesViewController = LandingViewController()
        countriesViewController.setup(for: .countries)

        let connectViewController = LandingViewController()
        connectViewController.setup(for: .connect)

        self.head.after = encryptionViewController
        encryptionViewController.before = self.head
        encryptionViewController.after = countriesViewController
        countriesViewController.before = encryptionViewController
        countriesViewController.after = connectViewController

        super.init()
    }

    func getCount(from item: LandingViewController) -> Int {
        var count = 1
        if let next = item.after {
            count += getCount(from: next)
        }
        return count
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let landingViewController = viewController as? LandingViewController {
            return landingViewController.before
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let landingViewController = viewController as? LandingViewController {
            return landingViewController.after
        }
        return nil
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return getCount(from: head)
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
