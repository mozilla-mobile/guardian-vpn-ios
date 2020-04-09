//
//  PersistenceLayer
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

private class CredentialsKeyChain {
    private static let containerKey = "org.mozilla.guardian.credentials"
    @KeychainStored<Credentials>(service: containerKey) var credentials: Credentials?
}

class PersistenceLayer: Persisting {

    private let userDefaults = UserDefaults.standard
    private let credentialsKeyChain = CredentialsKeyChain()

    func save<T>(value: T, for key: String) where T: Codable {
        do {
            let encoded = try JSONEncoder().encode(value)
            userDefaults.set(encoded, forKey: key)
        } catch {
            Logger.global?.log(message: error.localizedDescription)
        }
    }

    func readValue<T>(for key: String) -> T? where T: Codable {
        guard let decoded = userDefaults.object(forKey: key) as? Data else {
            return nil
        }
        do {
            return try JSONDecoder().decode(T.self, from: decoded)
        } catch {
            Logger.global?.log(message: error.localizedDescription)
            return nil
        }
    }

    func removeValue(for key: String) {
        userDefaults.removeObject(forKey: key)
    }

    func saveCredentials(_ credentials: Credentials) {
        credentialsKeyChain.credentials = credentials
    }

    func readCredentials() -> Credentials? {
        return credentialsKeyChain.credentials
    }

    func removeCredentials() {
        credentialsKeyChain.credentials = nil
    }
}
