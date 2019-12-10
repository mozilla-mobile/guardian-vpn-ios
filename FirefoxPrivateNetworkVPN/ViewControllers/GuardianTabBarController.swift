//
//  GuardianTabBarController
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

class GuardianTabBarController: UITabBarController, Navigating {
    static var navigableItem: NavigableItem = .tab

    private let tabs: [NavigableItem: UIViewController]

    init() {
        let navigationController = UINavigationController(rootViewController: SettingsViewController())
        navigationController.navigationBar.setTitleFont()
        navigationController.navigationBar.barTintColor = UIColor.custom(.grey5)

        tabs = [.home: HomeViewController(),
                .settings: navigationController]
        super.init(nibName: nil, bundle: nil)
        viewControllers = [tabs[.home]!, tabs[.settings]!]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        styleViews()
    }

    func displayTab(_ item: NavigableItem) {
        if let tab = tabs[item] {
            selectedViewController = tab
        }
    }

    func tab(_ item: NavigableItem) -> UIViewController? {
        return tabs[item]
    }

    private func styleViews() {
        tabBar.tintColor = UIColor.custom(.blue50)
        tabBar.unselectedItemTintColor = UIColor.custom(.grey40)
        tabBar.barTintColor = UIColor.custom(.grey5)
        tabBar.isTranslucent = true
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.custom(.inter, size: 11)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.custom(.inter, size: 11)], for: .selected)
    }
}
