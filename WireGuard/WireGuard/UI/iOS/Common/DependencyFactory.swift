// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

class DependencyFactory: DependencyProviding {
    static let sharedFactory = DependencyFactory()

    var userManager: UserManagerProtocol {
        return user
    }

    private let user: UserManagerProtocol

    init() {
        self.user = UserManager.sharedManager
    }
}
