// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit

class GuardianTabBarController: UITabBarController {
    var homeVPNViewController: HomeVPNViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        createViewControllers()
        styleViews()
    }

    private func createViewControllers() {
        homeVPNViewController = HomeVPNViewController.init(nibName: String(describing: HomeVPNViewController.self), bundle: Bundle.main)
        homeVPNViewController.coordinatorDelegate = NavigationCoordinator.sharedCoordinator
        viewControllers = [homeVPNViewController]
    }

    private func styleViews() {
        tabBar.tintColor = UIColor.buttonBlue
        tabBar.isTranslucent = true
    }
}
