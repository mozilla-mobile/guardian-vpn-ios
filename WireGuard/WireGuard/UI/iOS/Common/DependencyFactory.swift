// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

class DependencyFactory: DependencyProviding {
    static let sharedFactory = DependencyFactory()

    var userManager: UserManaging {
        return user
    }

    private let user: UserManaging

    init() {
        self.user = UserManager.sharedManager
    }
}
