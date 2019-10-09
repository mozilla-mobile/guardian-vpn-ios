// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

class DependencyFactory: DependencyProviding {
    static let sharedFactory = DependencyFactory()

    var userManager: AccountManaging {
        return user
    }

    private let user: AccountManaging

    init() {
        self.user = AccountManager.sharedManager
    }
}
