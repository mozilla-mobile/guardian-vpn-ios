// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import UIKit

class GuardianTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        styleViews()
    }

    init(viewControllers: [UIViewController]) {
        super.init(nibName: nil, bundle: Bundle.main)
        self.viewControllers = viewControllers
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func styleViews() {
        tabBar.tintColor = UIColor.buttonBlue
        tabBar.isTranslucent = true
    }
}
