// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import Foundation

enum NavigationAction {
    case loginSucceeded
    case loginFailed
    case vpnNewSelection
}

protocol Navigating: class {
    func navigate(after action: NavigationAction)
}
