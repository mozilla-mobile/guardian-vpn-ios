//
//  UserDefaulting
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

protocol UserDefaulting: Codable {
    static var userDefaultsKey: String { get }
}

extension UserDefaulting {
    static func fetchFromUserDefaults() -> Self? {
        guard let decoded = UserDefaults.standard.object(forKey: Self.userDefaultsKey) as? Data,
            let response = try? JSONDecoder().decode(Self.self, from: decoded) else {
                return nil
        }
        return response
    }

    static var existsInDefaults: Bool {
        return UserDefaults.standard.object(forKey: Self.userDefaultsKey) != nil
    }

    static func removeFromUserDefaults() {
        UserDefaults.standard.removeObject(forKey: Self.userDefaultsKey)
    }

    func saveToUserDefaults() {
        do {
            let encoded = try JSONEncoder().encode(self)
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: Self.userDefaultsKey)
            defaults.synchronize()

        } catch {
            print(error) // TODO: Handle this
        }
    }
}
