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
        case user
        case device
        case vpnServers
        case selectedCity
        case releaseInfo
    }

    let userDefaults: UserDefaults

    // MARK: - Lifecycle
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - API
    func saveValue<T>(forKey key: Key, value: T) where T: Codable {
        do {
            let encoded = try JSONEncoder().encode(value)
            userDefaults.set(encoded, forKey: key.rawValue)
            userDefaults.synchronize()

        } catch {
            print(error) // TODO: Handle this
        }
    }

    func readValue<T>(forKey key: Key) -> T? where T: Codable {
        guard let decoded = userDefaults.object(forKey: key.rawValue) as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: decoded)
    }

    func removeAll() {
        Key
            .allCases
            .forEach { userDefaults.removeObject(forKey: $0.rawValue) }
    }
}
