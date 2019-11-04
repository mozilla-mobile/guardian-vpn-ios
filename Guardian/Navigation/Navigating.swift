//
//  Navigating
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import Foundation

protocol Navigating {
    static var navigableItem: NavigableItem { get }
}

extension Navigating {
    func navigate(to screen: NavigableItem, context: [String: Any?]? = nil) {
        DependencyFactory.sharedFactory.navigationCoordinator.navigate(from: Self.navigableItem, to: screen, context: context)
    }
}
