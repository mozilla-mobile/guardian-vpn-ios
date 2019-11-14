//
//  NavigationCoordinating
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

protocol NavigationCoordinating {
    var firstViewController: UIViewController { get }

    func navigate(from: NavigableItem, to: NavigableItem)
    func navigate(from: NavigableItem, to: NavigableItem, context: NavigableContext?)
    func homeTab(isEnabled: Bool)
}

extension NavigationCoordinating {
    func navigate(from origin: NavigableItem, to destination: NavigableItem) {
        navigate(from: origin, to: destination, context: nil)
    }
}
