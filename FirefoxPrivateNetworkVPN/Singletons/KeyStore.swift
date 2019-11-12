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

class Credentials: UserDefaulting {
    static var userDefaultsKey = "credentials"

    private(set) var deviceKeys: DeviceKeys {
        didSet {
            saveToUserDefaults()
        }
    }

    private(set) var verificationToken: String {
        didSet {
            saveToUserDefaults()
        }
    }

    init(with userDefaults: Credentials) {
        deviceKeys = userDefaults.deviceKeys
        verificationToken = userDefaults.verificationToken
    }

    init(with verification: VerifyResponse) {
        Credentials.removeFromUserDefaults()
        let privateKey = Curve25519.generatePrivateKey()
        deviceKeys = DeviceKeys(privateKey: privateKey, publicKey: Curve25519.generatePublicKey(fromPrivateKey: privateKey))
        verificationToken = verification.token
    }

    func setVerification(token: String) {
        verificationToken = token
    }
}

struct DeviceKeys: Codable {
    let privateKey: Data
    let publicKey: Data
}
