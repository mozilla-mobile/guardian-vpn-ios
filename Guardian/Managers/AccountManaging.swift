// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import Foundation
import RxSwift

protocol AccountManaging {
    var user: User? { get }
    var token: String? { get }
    var currentDevice: Device? { get }
    var availableServers: [VPNCountry]? { get }
    var heartbeatFailedEvent: PublishSubject<Void> { get }

    /**
     This call is used to retrieve the link to the login page.
     */
    func login(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void)

    /**
     This should only be called from the initial login flow.
     */
    func setupFromVerify(url: URL, completion: @escaping (Result<Void, Error>) -> Void)
    func finishSetupFromVerify(completion: @escaping (Result<Void, Error>) -> Void)

    /**
     This should be called when the app is returned from foreground/launch and we've already logged in.
     */
    func setupFromAppLaunch(completion: @escaping (Result<Void, Error>) -> Void)

    func startHeartbeat()
    func pollUser()
    func countryCodeForCity(_ city: String) -> String?
    func logout(completion: @escaping (Result<Void, Error>) -> Void)
}
