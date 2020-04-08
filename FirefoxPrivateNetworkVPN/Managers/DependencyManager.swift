//
//  DependencyManager
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit

class DependencyManager: DependencyProviding {

    static let shared: DependencyProviding = DependencyManager()

    private init() { }

    // MARK: -
    private let networkLayer: Networking = NetworkLayer()
    private let persistenceLayer: Persisting = PersistenceLayer()
    private lazy var accountStore: AccountStoring = AccountStore(persistenceLayer: persistenceLayer)

    // MARK: -
    lazy var guardianAPI = GuardianAPI(networkLayer: networkLayer,
                                       userAgentInfo: NetworkingUtilities.userAgentInfo)
    lazy var accountManager: AccountManaging = AccountManager(guardianAPI: guardianAPI,
                                                              accountStore: accountStore,
                                                              deviceName: UIDevice.current.name)
    lazy var tunnelManager: TunnelManaging = {
        #if targetEnvironment(simulator)
          return SimulatorTunnelManager()
        #else
          return GuardianTunnelManager()
        #endif
    }()
    lazy var navigationCoordinator: NavigationCoordinating = NavigationCoordinator()
    lazy var connectionHealthMonitor: ConnectionHealthMonitoring = ConnectionHealthMonitor()
    lazy var releaseMonitor: ReleaseMonitoring = ReleaseMonitor(accountStore: accountStore, guardianAPI: guardianAPI)
    lazy var heartbeatMonitor: HeartbeatMonitoring = HeartbeatMonitor()
}
