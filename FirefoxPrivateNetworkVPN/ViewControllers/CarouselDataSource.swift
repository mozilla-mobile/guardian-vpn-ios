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

class CarouselDataSource: NSObject, UIPageViewControllerDataSource {

    private(set) lazy var lastIndex: Int = {
        return self.viewControllers.endIndex - 1
    }()

    private(set) lazy var viewControllers: [CarouselViewController] = {
        let noLogsViewController = CarouselViewController(for: .noLogs)
        let encryptionViewController = CarouselViewController(for: .encryption)
        let manyServersViewController = CarouselViewController(for: .manyServers)
        let getStartedViewController = CarouselViewController(for: .getStarted)

        return [noLogsViewController, encryptionViewController, manyServersViewController, getStartedViewController]
    }()

    func index(of viewController: UIViewController) -> Int? {
        guard let carouselViewController = viewController as? CarouselViewController else { return nil }
        return viewControllers.firstIndex(of: carouselViewController)
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = index(of: viewController), currentIndex > 0 else { return nil }

        return viewControllers[currentIndex - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = index(of: viewController), currentIndex < lastIndex else { return nil }

        return viewControllers[currentIndex + 1]
    }
}
