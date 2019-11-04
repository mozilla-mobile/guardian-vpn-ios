//
//  GuardianTabBarController
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit

class GuardianTabBarController: UITabBarController, Navigating {
    static var navigableItem: NavigableItem = .tab

    private let tabs: [NavigableItem: (UIViewController & Navigating)]

    init() {
        tabs = [.home: HomeViewController(),
                .settings: SettingsViewController()]
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

    private func styleViews() {
        tabBar.tintColor = UIColor.custom(.blue50)
        tabBar.unselectedItemTintColor = UIColor.custom(.grey30)
        tabBar.isTranslucent = true
    }
}
