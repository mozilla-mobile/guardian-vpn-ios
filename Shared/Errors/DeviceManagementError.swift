//
//  DeviceManagementError
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

enum DeviceManagementError: LocalizedError, Equatable {
    case couldNotRemoveDevice(Device)
    case couldNotAddDevice
    case maxDevicesReached
    case noPublicKey

    var errorDescription: String? {
        switch self {
        case .couldNotRemoveDevice:
            return LocalizedString.errorDeviceRemoval.value
        case .maxDevicesReached:
            return LocalizedString.devicesLimitSubtitle.value
        case .couldNotAddDevice, .noPublicKey:
            return nil
        }
    }
}
