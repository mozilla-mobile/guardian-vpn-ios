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

//    static let shared: Credentials = {
//        let instance = Credentials()
//        //
//        return instance
//    }()

    private let userEmail: String?

    private(set) var deviceKeys: DeviceKeys {
        didSet {
            saveToUserDefaults()
        }
    }

    private(set) var verificationToken: String? {
        didSet {
            saveToUserDefaults()
        }
    }

    init() {
        if let userDefaults = Credentials.fetchFromUserDefaults() {
            deviceKeys = userDefaults.deviceKeys
            verificationToken = userDefaults.verificationToken
            userEmail = userDefaults.userEmail
            return
        }
        let privateKey = Curve25519.generatePrivateKey()
        deviceKeys = DeviceKeys(privateKey: privateKey, publicKey: Curve25519.generatePublicKey(fromPrivateKey: privateKey))
        userEmail = nil
    }

    init(with verification: VerifyResponse) {
        if let userDefaults = Credentials.fetchFromUserDefaults(),
            verification.user.email == userDefaults.userEmail {
            deviceKeys = userDefaults.deviceKeys
            verificationToken = userDefaults.verificationToken
            userEmail = userDefaults.userEmail
            return
        }

        Credentials.removeFromUserDefaults()
        let privateKey = Curve25519.generatePrivateKey()
        deviceKeys = DeviceKeys(privateKey: privateKey, publicKey: Curve25519.generatePublicKey(fromPrivateKey: privateKey))
        userEmail = verification.user.email
        verificationToken = verification.token
    }

//    func resetDevice(privateKey: Data = Curve25519.generatePrivateKey()) {
//        deviceKeys = DeviceKeys(privateKey: privateKey, publicKey: Curve25519.generatePublicKey(fromPrivateKey: privateKey))
//    }
//
    func setVerification(token: String) {
        verificationToken = token
    }
//
//    func clearVerificationToken() {
//        verificationToken = nil
//    }
}

struct DeviceKeys: Codable {
    let privateKey: Data
    let publicKey: Data
}
