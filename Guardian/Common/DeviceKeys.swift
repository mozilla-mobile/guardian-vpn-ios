// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

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
