// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

enum NavigationAction {
    case loginSucceeded
    case loginFailed
    case vpnNewSelection
}

protocol Navigating: class {
    func navigate(after action: NavigationAction)
}
