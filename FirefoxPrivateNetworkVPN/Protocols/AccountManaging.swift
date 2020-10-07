//
//  AccountManaging
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation
import RxSwift

protocol AccountManaging {
    var isSubscriptionActive: Observable<Bool> { get }
    var account: Account? { get }
    var availableServers: [VPNCountry] { get }
    var selectedCity: VPNCity? { get }

    // MARK: - Authentication
    func login(with verification: VerifyResponse, completion: @escaping (Result<Void, LoginError>) -> Void)
    func loginWithStoredCredentials() -> Bool
    func logout(completion: @escaping (Result<Void, GuardianAPIError>) -> Void)

    // MARK: - Account Operations
    func addCurrentDevice(completion: @escaping (Result<Void, DeviceManagementError>) -> Void)
    func getUser(completion: @escaping (Result<Void, AccountError>) -> Void)
    func remove(device: Device) -> Single<Void>

    // MARK: - VPN Server Operations
    func retrieveVPNServers(with token: String, completion: @escaping (Result<Void, GuardianAPIError>) -> Void)
    func updateSelectedCity(with newCity: VPNCity)
}
