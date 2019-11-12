//
//  DeviceKeys
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

//import Foundation
//
//struct DeviceKeys: UserDefaulting {
//    static var userDefaultsKey = "devicePrivateKeyUserDefaults"
//
//    let devicePrivateKey: Data
//    let devicePublicKey: Data
//
//    init(devicePrivateKey: Data) {
//        self.devicePrivateKey = devicePrivateKey
//        self.devicePublicKey = Curve25519.generatePublicKey(fromPrivateKey: devicePrivateKey)
//    }
//}
