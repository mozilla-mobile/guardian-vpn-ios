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
    lazy var guardianAPI = GuardianAPI(networkLayer: networkLayer, userAgentInfo: userAgentInfo)
    lazy var accountManager: AccountManaging = AccountManager(guardianAPI: guardianAPI,
                                                              accountStore: accountStore)
    lazy var tunnelManager: TunnelManaging = GuardianTunnelManager()
    lazy var navigationCoordinator: NavigationCoordinating = NavigationCoordinator()
    lazy var connectionHealthMonitor: ConnectionHealthMonitoring = ConnectionHealthMonitor()
    lazy var releaseMonitor: ReleaseMonitoring = ReleaseMonitor(accountStore: accountStore, guardianAPI: guardianAPI)
    lazy var heartbeatMonitor: HeartbeatMonitoring = HeartbeatMonitor()

    // MARK: - Utils
    private var userAgentInfo: String {
        return UIApplication.appNameWithoutSpaces + "/" + UIApplication.appVersion
            + " " + UIDevice.modelName + "/" + UIDevice.current.systemVersion
    }
}
