//
//  PageViewDataSource
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

class CarouselPageViewDataSource: NSObject {
    typealias Pages = (first: Page, count: Int)

    let pages: Pages

    private static var viewControllers: [LandingViewController] = {
        let activityLogsViewController = LandingViewController()
        activityLogsViewController.setup(for: .activityLogs)

        let encryptionViewController = LandingViewController()
        encryptionViewController.setup(for: .encryption)

        let countriesViewController = LandingViewController()
        countriesViewController.setup(for: .countries)

        let connectViewController = LandingViewController()
        connectViewController.setup(for: .connect)

        return [activityLogsViewController, encryptionViewController, countriesViewController, connectViewController]
    }()

    override init() {
        self.pages = CarouselPageViewDataSource.setupPages(for: CarouselPageViewDataSource.viewControllers)
        super.init()
    }

    private static func setupPages(for viewControllers: [LandingViewController]) -> Pages {
        let first = Page(with: viewControllers.first!)
        var previous = first
        for each in viewControllers.dropFirst() {
            let page = Page(with: each)
            page.before = previous
            previous.after = page
            previous = page
        }
        return Pages(first: first, count: viewControllers.count)
    }
}

extension CarouselPageViewDataSource: UIPageViewControllerDataSource {

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
        return pages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

extension CarouselPageViewDataSource: UIPageViewControllerDelegate { }

class Page {
    let landingViewController: LandingViewController
    var before: Page?
    var after: Page?

    init(with landingViewController: LandingViewController) {
        self.landingViewController = landingViewController
    }
}
