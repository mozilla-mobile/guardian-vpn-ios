//
//  Navigating
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

protocol Navigating {
    static var navigableItem: NavigableItem { get }
}

extension Navigating {
    func navigate(to screen: NavigableItem, context: NavigableContext? = nil) {
        DependencyFactory.sharedFactory.navigationCoordinator.navigate(from: Self.navigableItem, to: screen, context: context)
    }
}
