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

class CarouselPageViewController: UIPageViewController, Navigating {
    static var navigableItem: NavigableItem = .carousel

    typealias Pages = (first: Page, count: Int)

    let pages: Pages
    var currentIndex = 0

    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        self.pages = CarouselPageViewController.setupPages(for: CarouselPageViewController.viewControllers)
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let carouselDataSource = self
        delegate = carouselDataSource
        dataSource = carouselDataSource

        setViewControllers([carouselDataSource.pages.first.landingViewController],
                           direction: .forward,
                           animated: true,
                           completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.custom(.grey5)
        navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_close"),
                                                                                style: .plain,
                                                                                target: self,
                                                                                action: #selector(self.closeCarousel))

        navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Skip",
                                                                                 style: .done,
                                                                                 target: self,
                                                                                 action: #selector(self.skipCarousel))
    }

    @objc func closeCarousel() {
        dismiss(animated: true, completion: nil)
    }

    @objc func skipCarousel() {
        //present last screen
        //hide page indicator
        //hide right bar button
    }
}
