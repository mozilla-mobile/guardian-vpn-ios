// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

class Account {
    var currentDevice: Device?
    var user: User
    var token: Token
    var availableServers: [VPNCountry]?

    init(user: User, token: Token, device: Device? = nil) {
        self.user = user
        self.token = token
        self.currentDevice = device
    }
}

extension Account: CustomStringConvertible {
    var description: String {
        return "" // TODO:
    }
}
