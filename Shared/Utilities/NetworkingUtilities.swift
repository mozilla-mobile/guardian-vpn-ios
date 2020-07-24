//
//  NetworkingUtilities
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

#if os(iOS)

import UIKit

class NetworkingUtilities {

    static var userAgentInfo: String {
        return UIApplication.appNameWithoutSpaces + "/" + UIApplication.appVersion
            + " " + UIDevice.modelName + "/" + UIDevice.current.systemVersion
    }

    static var deviceName: String {
        UIDevice.current.name
    }
}

#elseif os(macOS)

import AppKit

class NetworkingUtilities {

    static var userAgentInfo: String {
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersionString
        return NSApplication.appNameWithoutSpaces + "/" + NSApplication.appVersion
        + " " + Host.modelName + "/" + systemVersion
    }

    static var deviceName: String {
        Host.current().name ?? ""
    }
}

#endif
