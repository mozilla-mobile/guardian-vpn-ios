//
//  Persisting
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

protocol Persisting {
    func save<T>(value: T, for key: String) where T: Codable
    func readValue<T>(for key: String) -> T? where T: Codable
    func removeValue(for key: String)

    func saveCredentials(_ credentials: Credentials)
    func readCredentials() -> Credentials?
    func removeCredentials()
    func saveIAPCredentials(_ credentials: String)
    func readIAPCredentials() -> String?
    func removeIAPCredentials()
}
