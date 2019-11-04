//
//  UITabBarItem+Tagging
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
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
