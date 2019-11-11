//
//  KeyStore
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

class KeyStore {
    static let sharedStore: KeyStore = {
        let instance = KeyStore()
        //
        return instance
    }()

    let deviceKeys: DeviceKeys

    private init() {
        if let keys = DeviceKeys.fetchFromUserDefaults() {
            deviceKeys = keys
        } else {
            deviceKeys = DeviceKeys(devicePrivateKey: Curve25519.generatePrivateKey())
            deviceKeys.saveToUserDefaults()
        }
    }
}
