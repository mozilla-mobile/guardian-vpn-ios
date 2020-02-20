//
//  DependencyProviding
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

protocol DependencyProviding {
    var accountManager: AccountManaging { get }
    var tunnelManager: TunnelManaging { get }
    var navigationCoordinator: NavigationCoordinating { get }
    var connectionHealthMonitor: ConnectionHealthMonitoring { get }
    var releaseMonitor: ReleaseMonitoring { get }
    var heartbeatMonitor: HeartbeatMonitoring { get }
}
