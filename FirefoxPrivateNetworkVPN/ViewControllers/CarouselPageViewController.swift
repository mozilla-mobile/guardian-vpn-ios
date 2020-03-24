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

    private lazy var skipButton: UIBarButtonItem = {
        let skipButton = UIBarButtonItem(title: LocalizedString.landingSkip.value,
                        style: .done,
                        target: self,
                        action: #selector(self.skipToLastPage))
        skipButton.tintColor = .custom(.blue50)

        return skipButton
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
        super.viewDidLayoutSubviews()
        layoutPageControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if #available(iOS 13.0, *) {
            isPresentingViewControllerDimmed = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if #available(iOS 13.0, *) {
            isPresentingViewControllerDimmed = false
        }
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
        setupNavigationBarForModalPresentation()

        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.rightBarButtonItem = skipButton
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.custom(.metropolis, size: 17)], for: .normal)
    }

    private func layoutPageControl() {
        let viewHeight = view.frame.height
        let viewWidth = view.frame.width
        pageControl.center.x = viewWidth/2.0
        pageControl.center.y = viewHeight + Constant.pageControlOffsetY
    }

    private func reloadPage() {
        pageControl.isHidden = shouldHideControls
        navigationItem.rightBarButtonItem = shouldHideControls ? nil : skipButton
    }

    @objc override func closeModal() {
        navigate(to: .landing())
    }

    @objc func skipToLastPage() {
        setViewControllers([carouselDataSource.viewControllers.last!],
                           direction: .forward,
                           animated: true,
                           completion: nil)

        currentIndex = carouselDataSource.lastIndex
        reloadPage()
    }
}

extension CarouselPageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let nextViewController = pendingViewControllers.first,
            let nextIndex = carouselDataSource.index(of: nextViewController) {
            pendingIndex = nextIndex
            reloadPage()
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            currentIndex = pendingIndex ?? carouselDataSource.lastIndex
            pageControl.currentPage = currentIndex
        }
        pendingIndex = nil
        reloadPage()
    }
}
