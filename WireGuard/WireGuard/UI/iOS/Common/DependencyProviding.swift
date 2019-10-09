// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

protocol DependencyProviding: class {
    var userManager: AccountManaging { get }
}
