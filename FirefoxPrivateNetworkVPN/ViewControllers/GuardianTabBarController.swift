//
//  GuardianTabBarController
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit

class GuardianTabBarController: UITabBarController, Navigating {
    static var navigableItem: NavigableItem = .tab

    private let tabs: [NavigableItem: UIViewController]

    init() {
        tabs = [.home: HomeViewController(),
                .settings: UINavigationController(rootViewController: SettingsViewController())]
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
        tabBar.isTranslucent = true
    }
}
