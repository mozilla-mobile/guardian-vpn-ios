//
//  DependencyFactory
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

class DependencyFactory: DependencyProviding {

    static let sharedFactory: DependencyProviding = {
        return DependencyFactory()
    }()

    private init() { }

    var accountManager: AccountManaging {
        return AccountManager.sharedManager
    }

    var tunnelManager: TunnelManaging {
        return GuardianTunnelManager.sharedManager
    }

    var navigationCoordinator: NavigationCoordinating {
        return NavigationCoordinator.sharedCoordinator
    }

    lazy var connectionHealthMonitor: ConnectionHealthMonitoring = {
        return ConnectionHealthMonitor()
    }()

    var releaseMonitor: ReleaseMonitoring {
        return ReleaseMonitor.sharedManager
    }
}
