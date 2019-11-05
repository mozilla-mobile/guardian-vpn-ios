//
//  DependencyProviding
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import Foundation

protocol DependencyProviding {
    var accountManager: AccountManaging { get }
    var tunnelManager: TunnelManaging { get }
    var navigationCoordinator: NavigationCoordinating { get }
}
