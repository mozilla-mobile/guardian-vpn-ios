//
//  AccountRepository
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Foundation

class AccountStore {
    enum Key: String, CaseIterable {
        case user = "user"
        case device = "device"
        case vpnServers = "vpnServers"
    }
    
    let userDefaults: UserDefaults
    
    // MARK: - Lifecycle
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - API
    func saveValue(forKey key: Key, value: Any) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    func readValue<T>(forKey key: Key) -> T? {
        return userDefaults.value(forKey: key.rawValue) as? T
    }
    
    func removeAll() {
        Key
            .allCases
            .forEach { key in
                userDefaults.removeObject(forKey: key.rawValue)
        }
    }
}
