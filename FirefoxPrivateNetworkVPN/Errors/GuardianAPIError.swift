//
//  GuardianAPIError
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

enum GuardianAPIError: Int, LocalizedError {
    /** Errors from Guardian App
     */
    case offline = -1009
    case couldNotEncodeData = 4
    case couldNotDecodeJSON = 5

    /**
    Errors directly from Guardian API
    */
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

    var errorDescription: String? {
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

    func getAccountError() -> AccountError {
        switch self {
        case .inactiveSubscription, .tokenExpired, .tokenInvalid, .tokenNotFound, .userNotFound, .tokenNotVerified, .deviceNotFound:
            return .subscriptionError
        default:
            return .couldNotGetUser
        }
    }

    func getLoginError() -> LoginError {
        switch self {
        case .offline:
            return .noConnection
        case .maxDevicesReached:
            return .maxDevicesReached
        default:
            return .other(rawValue)
        }
    }
}
