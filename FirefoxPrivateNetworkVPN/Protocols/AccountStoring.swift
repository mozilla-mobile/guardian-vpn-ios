//
//  AccountStoring
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Foundation

protocol AccountStoring {

    func save(user: User)
    func getUser() -> User?

    func save(vpnServers: [VPNCountry])
    func getVpnServers() -> [VPNCountry]

    func save(currentDevice: Device)
    func getCurrentDevice() -> Device?

    func save(selectedCity: VPNCity)
    func getSelectedCity() -> VPNCity?

    func save(releaseInfo: ReleaseInfo)
    func getReleaseInfo() -> ReleaseInfo?

    func save(credentials: Credentials)
    func getCredentials() -> Credentials?

    func save(iapInfo: IAPInfo)
    func getIapInfo() -> IAPInfo?
    func removeIapInfo()

    func removeAll()
}
