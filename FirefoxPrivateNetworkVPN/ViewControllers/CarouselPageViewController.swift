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

    private struct Constant {
        static let pageControlOffsetY: CGFloat = -100
    }

    static var navigableItem: NavigableItem = .carousel

    private let pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: 43, height: 6))
    private let carouselDataSource = CarouselDataSource()

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .custom(.grey5)

        delegate = self
        dataSource = carouselDataSource

        setupPageControl()
        setViewControllers([carouselDataSource.viewControllers.first!],
                           direction: .forward,
                           animated: true,
                           completion: nil)
    }

    private func setupPageControl() {
        pageControl.pageIndicatorTintColor = .custom(.grey20)
        pageControl.currentPageIndicatorTintColor = .custom(.blue50)

        pageControl.numberOfPages = carouselDataSource.viewControllers.count

        view.addSubview(pageControl)
    }

    override func viewDidLayoutSubviews() {
        let viewHeight = view.frame.height
        let viewWidth = view.frame.width

        pageControl.center.x = viewWidth/2.0
        pageControl.center.y = viewHeight + Constant.pageControlOffsetY
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

extension CarouselPageViewController: UIPageViewControllerDelegate {

    //swiftlint:disable force_cast
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let nextViewController = pendingViewControllers.first as!  OnboardingViewController
        let index = carouselDataSource.viewControllers.firstIndex(of: nextViewController)

        pageControl.currentPage = index ?? 0
    }
}
