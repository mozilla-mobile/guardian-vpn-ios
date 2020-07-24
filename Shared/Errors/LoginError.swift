//
//  LoginError
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

enum LoginError: LocalizedError, Equatable {
    case maxDevicesReached
    case noConnection
    case couldNotAddDevice
    case couldNotGetServers
    case other(Int)

    var errorDescription: String? {
        switch self {
        case .maxDevicesReached:
            return LocalizedString.devicesLimitSubtitle.value
        case .noConnection:
            return LocalizedString.toastNoConnection.value
        case .couldNotAddDevice, .couldNotGetServers, .other:
            //Display authentication message regardless of error on warning toast for now
            return LocalizedString.toastAuthenticationError.value
        }
    }
}
