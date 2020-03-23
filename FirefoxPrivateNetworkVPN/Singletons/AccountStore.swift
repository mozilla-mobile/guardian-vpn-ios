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

class AccountStore: AccountStoring {

    private enum Key: String, CaseIterable {
        case user
        case device
        case vpnServers
        case selectedCity
        case releaseInfo
    }

    private let persistenceLayer: Persisting

    init(persistenceLayer: Persisting = PersistenceLayer.shared) {
        self.persistenceLayer = persistenceLayer
    }

    static let sharedManager = AccountStore()

    func save(user: User) {
        persistenceLayer.save(value: user, for: Key.user.rawValue)
    }

    func getUser() -> User? {
        return persistenceLayer.readValue(for: Key.user
            .rawValue)
    }

    func save(vpnServers: [VPNCountry]) {
        persistenceLayer.save(value: vpnServers, for: Key.vpnServers.rawValue)
    }

    func getVpnServers() -> [VPNCountry] {
        return persistenceLayer.readValue(for: Key.vpnServers
            .rawValue) ?? []
    }

    func save(currentDevice: Device) {
        persistenceLayer.save(value: currentDevice, for: Key.device.rawValue)
    }

    func getCurrentDevice() -> Device? {
        return persistenceLayer.readValue(for: Key.device
            .rawValue)
    }

    func save(selectedCity: VPNCity) {
        persistenceLayer.save(value: selectedCity, for: Key.selectedCity.rawValue)
    }

    func getSelectedCity() -> VPNCity? {
        return persistenceLayer.readValue(for: Key.selectedCity
            .rawValue)

    }

    func save(releaseInfo: ReleaseInfo) {
        persistenceLayer.save(value: releaseInfo, for: Key.releaseInfo.rawValue)
    }

    func getReleaseInfo() -> ReleaseInfo? {
        return persistenceLayer.readValue(for: Key.releaseInfo
            .rawValue)
    }

    func save(credentials: Credentials) {
        persistenceLayer.saveCredentials(credentials)
    }

    func getCredentials() -> Credentials? {
        return persistenceLayer.readCredentials()
    }

    func removeAll() {
        Key.allCases
            .forEach {
                persistenceLayer.removeValue(for: $0.rawValue)
        }
        persistenceLayer.removeCredentials()
    }
}
