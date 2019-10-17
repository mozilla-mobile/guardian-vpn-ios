// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation
import RxSwift

protocol AccountManaging {

    var credentialsStore: KeysStore { get }
    var user: User? { get }
    var token: String? { get }
    var currentDevice: Device? { get }
    var availableServers: [VPNCountry]? { get }
    var heartbeatFailedEvent: PublishSubject<Void> { get }

    func login(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void)
    func setupFromVerify(url: URL, completion: @escaping (Result<Void, Error>) -> Void)
    func setupFromAppLaunch(completion: @escaping (Result<Void, Error>) -> Void)
    func startHeartbeat()
}
