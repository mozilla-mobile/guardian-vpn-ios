//
//  UIApplication+appVersion
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

extension UIApplication {
    private static let appStoreURL = "itms-apps://itunes.apple.com/app/id1489407738"
    private static let bundleAppNameKey = "CFBundleName"
    private static let bundleVersionKey = "CFBundleShortVersionString"

    static var appName: String {
        return Bundle.main.object(forInfoDictionaryKey: UIApplication.bundleAppNameKey) as? String ?? ""
    }

    static var appNameWithoutSpaces: String {
        return appName.replacingOccurrences(of: " ", with: "")
    }

    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: UIApplication.bundleVersionKey) as? String ?? ""
    }

    func openAppStore() {
        if let url = URL(string: UIApplication.appStoreURL),
            canOpenURL(url) {
            open(url, options: [:], completionHandler: nil)
        }
    }
}

#elseif os(macOS)

import AppKit

extension NSApplication {
    private static let bundleAppNameKey = "CFBundleName"
    private static let bundleVersionKey = "CFBundleShortVersionString"

    static var appName: String {
        return Bundle.main.object(forInfoDictionaryKey: NSApplication.bundleAppNameKey) as? String ?? ""
    }

    static var appNameWithoutSpaces: String {
        return appName.replacingOccurrences(of: " ", with: "")
    }

    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: NSApplication.bundleVersionKey) as? String ?? ""
    }
}

extension NSWorkspace {
    private static let appStoreURL = "itms-apps://itunes.apple.com/app/id1489407738"

    func openAppStore() {
        if let url = URL(string: NSWorkspace.appStoreURL) {
            open(url)
        }
    }
}

#endif
