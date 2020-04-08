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
