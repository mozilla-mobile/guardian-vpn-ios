//
//  NavigationCoordinating
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit

protocol NavigationCoordinating {
    var firstViewController: UIViewController { get }

    func navigate(from: NavigableItem, to: NavigableItem)
    func navigate(from: NavigableItem, to: NavigableItem, context: [String: Any?]?)
}

extension NavigationCoordinating {
    func navigate(from origin: NavigableItem, to destination: NavigableItem) {
        navigate(from: origin, to: destination, context: nil)
    }
}
