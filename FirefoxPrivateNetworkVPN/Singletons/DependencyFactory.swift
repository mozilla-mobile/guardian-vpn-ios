//
//  DependencyFactory
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import Foundation

class DependencyFactory: DependencyProviding {

    static let sharedFactory: DependencyProviding = {
        let instance = DependencyFactory()
        //
        return instance
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
}
