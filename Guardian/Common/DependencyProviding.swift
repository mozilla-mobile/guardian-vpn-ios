// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import Foundation

protocol DependencyProviding: class {
    var accountManager: AccountManaging { get }
    var tunnelManager: GuardianTunnelManager { get }
}
