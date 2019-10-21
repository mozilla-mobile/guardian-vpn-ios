// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

class KeyStore {
    static let sharedStore = KeyStore()
    let deviceKeys: DeviceKeys

    init() {
        if let keys = DeviceKeys.fetchFromUserDefaults() {
            deviceKeys = keys
        } else {
            deviceKeys = DeviceKeys(devicePrivateKey: Curve25519.generatePrivateKey())
            deviceKeys.saveToUserDefaults()
        }
    }
}
