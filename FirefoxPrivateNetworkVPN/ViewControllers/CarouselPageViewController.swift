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
    private var currentIndex = 0
    private var pendingIndex: Int?

    private var isLastPage: Bool {
        return currentIndex == carouselDataSource.lastIndex
    }

    private var isLastPageNext: Bool {
        return currentIndex == carouselDataSource.lastIndex - 1
            && pendingIndex == carouselDataSource.lastIndex
    }

    private var shouldHideControls: Bool {
        return isLastPage || isLastPageNext
    }

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: 43, height: 6))
        pageControl.pageIndicatorTintColor = .custom(.grey20)
        pageControl.currentPageIndicatorTintColor = .custom(.blue50)
        pageControl.numberOfPages = carouselDataSource.viewControllers.count

        return pageControl
    }()

    private lazy var closeButton: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "icon_close"),
                               style: .plain,
                               target: self,
                               action: #selector(self.close))
    }()

    private lazy var skipButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "Skip",
                        style: .done,
                        target: self,
                        action: #selector(self.skipToLastPage))
    }()

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = carouselDataSource

        setupViews()
        setupNavigationBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutPageControl()
    }

    private func setupViews() {
        view.backgroundColor = .custom(.grey5)
        view.addSubview(pageControl)

        setViewControllers([carouselDataSource.viewControllers.first!],
                           direction: .forward,
                           animated: true,
                           completion: nil)
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.custom(.grey5)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = skipButton
    }

    private func layoutPageControl() {
        let viewHeight = view.frame.height
        let viewWidth = view.frame.width
        pageControl.center.x = viewWidth/2.0
        pageControl.center.y = viewHeight + Constant.pageControlOffsetY
    }

    private func reformatPage() {
        pageControl.isHidden = shouldHideControls
        navigationItem.rightBarButtonItem = shouldHideControls ? nil : skipButton
    }

    @objc func close() {
        dismiss(animated: true, completion: nil)
    }

    @objc func skipToLastPage() {
        setViewControllers([carouselDataSource.viewControllers.last!],
                           direction: .forward,
                           animated: true,
                           completion: nil)

        currentIndex = carouselDataSource.lastIndex
        reformatPage()
    }
}

extension CarouselPageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let nextViewController = pendingViewControllers.first,
            let nextIndex = carouselDataSource.index(of: nextViewController) {
            pendingIndex = nextIndex
            reformatPage()
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentIndex = pendingIndex ?? carouselDataSource.lastIndex
            pageControl.currentPage = currentIndex
        }
        pendingIndex = nil
        reformatPage()
    }
}
