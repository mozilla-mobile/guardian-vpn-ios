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
    var user: User? { get }
    var credentials: Credentials { get }
    var currentDevice: Device? { get }
    var availableServers: [VPNCountry]? { get }
    var heartbeatFailedEvent: PublishSubject<Void> { get }

    func logout(completion: @escaping (Result<Void, Error>) -> Void)
//    func setupFromAppLaunch(completion: @escaping (Result<Void, Error>) -> Void)
//    func setupFromVerification(completion: @escaping (Result<Void, Error>) -> Void)
    func finishSetup(completion: @escaping (Result<Void, Error>) -> Void)
    func removeDevice(with deviceKey: String, completion: @escaping (Result<Void, Error>) -> Void)
    func addDevice(completion: @escaping (Result<Device, Error>) -> Void)

    func startHeartbeat()
    func countryCodeForCity(_ city: String) -> String?
}
