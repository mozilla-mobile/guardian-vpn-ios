// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

class Account {
    var currentDevice: Device?
    var user: User
    var token: String
    var availableServers: [VPNCountry]?

    init(user: User, token: String) {
        self.user = user
        self.token = token
    }
}
