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
    var account: Account? { get }
    var availableServers: [VPNCountry]? { get }
    //remove later
    var accountStore: AccountStore { get }

    func login(with verification: VerifyResponse, completion: @escaping (Result<Void, Error>) -> Void)
    func loginWithStoredCredentials() -> Bool
    func logout(completion: @escaping (Result<Void, Error>) -> Void)
    func retrieveVPNServers(with token: String, completion: @escaping (Result<Void, Error>) -> Void)
}
