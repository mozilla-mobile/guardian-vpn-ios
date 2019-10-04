// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

enum NavigationAction {
    case manualLoginSucceeded
    case vpnNewSelection
}

protocol NavigationProtocol: class {
    func navigate(after action: NavigationAction)
}
