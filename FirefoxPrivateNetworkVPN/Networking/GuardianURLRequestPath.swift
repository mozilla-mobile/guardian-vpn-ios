//
//  GuardianURLRequestPath
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

enum GuardianURLRequestPath {
    case login
    case verify
    case retrieveServers
    case account
    case addDevice
    case removeDevice(String)
    case versions

    var endpoint: String {
        let prefix = "api/v1/vpn/"
        let v2Prefix = "api/v2/vpn/"
        switch self {
        case .login:
            return v2Prefix + "login/ios"
        case .verify:
            return v2Prefix + "login/verify"
        case .retrieveServers:
            return prefix + "servers"
        case .account:
            return prefix + "account"
        case .addDevice:
            return prefix + "device"
        case .removeDevice(let deviceKey):
            return prefix + "device/" + deviceKey
        case .versions:
            return prefix + "versions"
        }
    }
}
