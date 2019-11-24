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

    lazy var lastIndex: Int = {
        return self.viewControllers.endIndex - 1
    }()

    lazy var viewControllers: [OnboardingViewController] = {
        let noLogsViewController = OnboardingViewController(for: .noLogs)
        let encryptionViewController = OnboardingViewController(for: .encryption)
        let manyServersViewController = OnboardingViewController(for: .manyServers)
        let getStartedViewController = OnboardingViewController(for: .getStarted)

        return [noLogsViewController, encryptionViewController, manyServersViewController, getStartedViewController]
    }()

    func index(of viewController: UIViewController) -> Int? {
        guard let onboardingViewController = viewController as? OnboardingViewController else { return nil }
        return viewControllers.firstIndex(of: onboardingViewController)
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
