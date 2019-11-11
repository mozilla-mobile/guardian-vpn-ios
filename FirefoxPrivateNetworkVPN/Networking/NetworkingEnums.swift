//
//  NetworkingEnums
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

enum GuardianFailReason: String, Error {
    case no200 = "Response status code not 200"
    case couldNotDecodeFromJson = "Could not decode from JSON"
    case loginError = "Login error"
    case emptyToken = "User could not be verified"
    case couldNotCreateBody = "Could not create body"
    case couldNotFetchDevice = "Could not fetch device from user defaults"
    case deviceKeyFailure = "Could not generate device key"
}

enum HTTPMethod: String {
    case GET
    case POST
    case DELETE
}

enum GuardianRelativeRequest {
    case login
    case verify(String)
    case retrieveServers
    case account
    case addDevice
    case removeDevice(String)

    var endpoint: String {
        switch self {
        case .login:
            return "/api/v1/vpn/login/"
        case .verify(let token):
            return "/api/v1/vpn/login/verify/" + token
        case .retrieveServers:
            return "/api/v1/vpn/servers/"
        case .account:
            return "/api/v1/vpn/account/"
        case .addDevice:
            return "/api/v1/vpn/device/"
        case .removeDevice(let deviceKey):
            return "/api/v1/vpn/device/" + deviceKey
        }
    }
}
