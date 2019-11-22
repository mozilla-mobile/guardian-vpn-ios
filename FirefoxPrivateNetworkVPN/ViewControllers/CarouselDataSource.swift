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

    lazy var viewControllers: [OnboardingViewController] = {
        let activityLogsViewController = OnboardingViewController(for: .activityLogs)
        let encryptionViewController = OnboardingViewController(for: .encryption)
        let countriesViewController = OnboardingViewController(for: .countries)
        let connectViewController = OnboardingViewController(for: .connect)

        return [activityLogsViewController, encryptionViewController, countriesViewController, connectViewController]
    }()

    //swiftlint:disable force_cast
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = viewControllers.firstIndex(of: viewController as! OnboardingViewController) ?? 0
        guard currentIndex > 0 else { return nil }

        return viewControllers[currentIndex - 1]
    }

    //swiftlint:disable force_cast
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = viewControllers.firstIndex(of: viewController as! OnboardingViewController) ?? 0
        guard currentIndex < viewControllers.count - 1 else { return nil }

        return viewControllers[currentIndex + 1]
    }
}
