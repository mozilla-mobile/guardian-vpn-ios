//
//  TunnelError
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

enum TunnelError: LocalizedError {
    case couldNotConnect
    case couldNotSwitch

    var errorDescription: String? {
        switch self {
        case .couldNotConnect, .couldNotSwitch:
            return LocalizedString.errorConnectVPN.value
        }
    }
}
