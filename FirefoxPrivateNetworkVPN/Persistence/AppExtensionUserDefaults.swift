//
//  AppExtensionUserDefaults
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Foundation

struct AppExtensionUserDefaults {

    // MARK: - Init

    static let standard = AppExtensionUserDefaults()

    private init() {}

    // MARK: - Property

    private let userDefaults = UserDefaults(suiteName: "group.org.mozilla.ios.Guardian")

    // MARK: - Method

    func set(_ value: Any?, forKey key: AppExtensionKey) {
        userDefaults?.set(value, forKey: key.rawValue)
    }

    func value(forKey key: AppExtensionKey) -> Any? {
        return userDefaults?.value(forKey: key.rawValue)
    }

    // MARK: - internal enum

    enum AppExtensionKey: String {
        case isSwitchingInProgress
    }
}
