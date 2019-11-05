//
//  KeyStore
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
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
