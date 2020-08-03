//
//  Account
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import RxSwift

class Account {
    var credentials: Credentials
    var currentDevice: Device?
    var user: User

    init(credentials: Credentials, user: User, currentDevice: Device? = nil) {
        self.credentials = credentials
        self.user = user
        self.currentDevice = currentDevice
    }

    var token: String {
        return credentials.verificationToken
    }

    var publicKey: Data {
        return credentials.deviceKeys.publicKey
    }

    var privateKey: Data {
        return credentials.deviceKeys.privateKey
    }

    var hasDeviceBeenAdded: Bool {
        return currentDevice != nil
    }

    var isSubscriptionActive: Bool {
        return user.vpnSubscription.isActive
    }
}
