// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

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
