// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

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
