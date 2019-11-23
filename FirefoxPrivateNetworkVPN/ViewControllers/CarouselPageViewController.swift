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

    private struct Constant {
        static let pageControlOffsetY: CGFloat = -100
    }

    private let carouselDataSource = CarouselDataSource()
    private let pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: 43, height: 6))
    private var currentIndex = 0
    private var pendingIndex = 1

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
        setupNavigationBar()

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

    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.custom(.grey5)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_close"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(self.closeCarousel))
        skipButton(isHidden: false)
    }
    
    private func skipButton(isHidden: Bool) {
        guard !isHidden else {
            navigationItem.rightBarButtonItem = nil
            return
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Skip",
        style: .done,
        target: self,
        action: #selector(self.skipCarousel))
    }

    @objc func closeCarousel() {
        dismiss(animated: true, completion: nil)
    }

    @objc func skipCarousel() {
        setViewControllers([carouselDataSource.viewControllers.last!],
                           direction: .forward,
                           animated: true,
                           completion: nil)
        pageControl.isHidden = true
        skipButton(isHidden: true)
    }
}

extension CarouselPageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        //swiftlint:disable force_cast
        let nextViewController = pendingViewControllers.first as! OnboardingViewController
        pendingIndex = carouselDataSource.viewControllers.firstIndex(of: nextViewController)!
        let lastIndex = carouselDataSource.viewControllers.endIndex - 1
        pageControl.isHidden = (currentIndex == lastIndex - 1 && pendingIndex == lastIndex)
            || (currentIndex == lastIndex && pendingIndex == lastIndex - 1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let lastIndex = carouselDataSource.viewControllers.endIndex - 1

        if completed {
            currentIndex = pendingIndex
            pageControl.currentPage = currentIndex
            pageControl.isHidden = currentIndex == lastIndex
            if currentIndex < lastIndex {
                skipButton(isHidden: false)
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        } else {
            pageControl.isHidden = !(currentIndex < lastIndex)
        }
    }
}
