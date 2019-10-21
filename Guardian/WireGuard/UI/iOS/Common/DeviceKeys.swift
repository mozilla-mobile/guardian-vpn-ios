// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

struct DeviceKeys: UserDefaulting {
    static var userDefaultsKey = "devicePrivateKeyUserDefaults"
    let devicePrivateKey: Data
    let devicePublicKey: Data

    init(devicePrivateKey: Data) {
        self.devicePrivateKey = devicePrivateKey
        self.devicePublicKey = Curve25519.generatePublicKey(fromPrivateKey: devicePrivateKey)
    }
}
