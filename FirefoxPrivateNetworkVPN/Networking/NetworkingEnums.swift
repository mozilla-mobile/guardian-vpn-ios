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

enum GuardianError: Error {
    case couldNotDecodeFromJson
    case couldNotCreateBody
    case couldNotEncodeData
    case missingData
    case needToLogin
    case deallocated

    var description: String {
        switch self {
        case .couldNotDecodeFromJson:
            return "Could not decode from JSON"
        case .couldNotCreateBody:
            return "Could not create body"
        case .couldNotEncodeData:
            return "Could not encode data"
        case .missingData:
            return "Missing data"
        case .needToLogin:
            return "Need to login"
        case .deallocated:
            return "Object has been deallocated"
        }
    }
}

enum GuardianAPIError: Int, Error {
    // Add Device
    case missingPubKey = 100
    case missingName = 101
    case invalidPubKey = 102
    case pubKeyAlreadyInUse = 103
    case maxDevicesReached = 104

    // Remove Device
    case pubKeyNotFound = 105

    // Authorization
    case tokenInvalid = 120
    case userNotFound = 121
    case deviceNotFound = 122
    case inactiveSubscription = 123

    // Authentication
    case tokenNotFound = 124
    case tokenExpired = 125
    case tokenNotVerified = 126

    // Unknown
    case unknown = 500

    var description: String {
        switch self {
        case .missingPubKey:
            return "Missing key argument"
        case .missingName:
            return "Missing name argument"
        case .invalidPubKey:
            return "Not a valid WireGuard key"
        case .pubKeyAlreadyInUse:
            return "WireGuard key already used by other account"
        case .maxDevicesReached:
            return "The account has already reached the maximum allowed devices"
        case .pubKeyNotFound:
            return "A device with that key does not exist"
        case .tokenInvalid:
            return "Invalid token"
        case .userNotFound:
            return "User not found"
        case .deviceNotFound:
            return "Device not found"
        case .inactiveSubscription:
            return "User doesn’t have an active subscription"
        case .tokenNotFound:
            return "Login token not found"
        case .tokenExpired:
            return "Login token expired"
        case .tokenNotVerified:
            return "Login token isn't verified"
        default:
            return "Unknown error"
        }
    }
}
