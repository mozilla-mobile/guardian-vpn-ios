//
//  UITabBarItem+Tagging
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

enum TabTag: Int {
    case home = 0
    case settings = 1
}

extension UITabBarItem {
    convenience init(title: String?, image: UIImage?, tag: TabTag) {
        self.init(title: title, image: image, tag: tag.rawValue)
    }
}
