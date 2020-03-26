//
//  GuardianAppError
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

enum GuardianAppError: Error {
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
