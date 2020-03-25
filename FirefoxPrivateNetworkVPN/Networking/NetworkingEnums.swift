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
    case versions

    var endpoint: String {
        let prefix = "api/v1/vpn/"
        switch self {
        case .login:
            return prefix + "login/"
        case .verify(let token):
            return prefix + "login/verify/" + token
        case .retrieveServers:
            return prefix + "servers/"
        case .account:
            return prefix + "account/"
        case .addDevice:
            return prefix + "device/"
        case .removeDevice(let deviceKey):
            return prefix + "device/" + deviceKey
        case .versions:
            return prefix + "versions"
        }
    }
}

enum GuardianError: Error {
    case noValidAccount
    case couldNotDecodeFromJson
    case couldNotCreateBody
    case couldNotEncodeData
    case missingData
    case needToLogin
    case deallocated
    case couldNotRemoveDevice(Device)
    case couldNotConnectVPN

    var description: String {
        switch self {
        case .noValidAccount:
            return "No valid account exists"
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
        case .couldNotRemoveDevice:
            return LocalizedString.errorDeviceRemoval.value
        case .couldNotConnectVPN:
            return LocalizedString.errorConnectVPN.value
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

    // No internet connection
    case offline = -1009

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
        case .offline:
            return "The Internet connection appears to be offline."
        default:
            return "Unknown error"
        }
    }

    var isAuthError: Bool {
        switch self {
        case .inactiveSubscription, .tokenExpired, .tokenInvalid, .tokenNotFound, .userNotFound, .tokenNotVerified, .deviceNotFound:
            return true
        default:
            return false
        }
    }
}
