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
    var account: Account? { get}
    var availableServers: [VPNCountry]? { get }

    func login(with verification: VerifyResponse, completion: @escaping (Result<Void, Error>) -> Void)
    func loginWithStoredCredentials(completion: @escaping (Result<Void, Error>) -> Void)
    func logout(completion: @escaping (Result<Void, Error>) -> Void)

    //TODO: Move to another class
    var heartbeatFailedEvent: PublishSubject<Void> { get }

    func startHeartbeat()
    func countryCodeForCity(_ city: String) -> String?
}
