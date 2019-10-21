// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

class DependencyFactory: DependencyProviding {
    static let sharedFactory = DependencyFactory()

    var tunnelManager: GuardianTunnelManager {
        return GuardianTunnelManager.sharedTunnelManager
    }

    var accountManager: AccountManaging {
        return AccountManager.sharedManager
    }
}
