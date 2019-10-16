// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation
import RxSwift

protocol AccountManaging {
    var account: Account? { get }
    var credentialsStore: CredentialsStore { get }
    var heartbeatFailedEvent: PublishSubject<Void> { get }

    func set(with: Account, completion: ((Result<Void, Error>) -> Void))
    func login(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void)
    func verify(url: URL, completion: @escaping (Result<VerifyResponse, Error>) -> Void)
    func retrieveUser(completion: @escaping (Result<User, Error>) -> Void)
    func retrieveVPNServers(completion: @escaping (Result<[VPNCountry], Error>) -> Void)
    func addDevice(completion: @escaping (Result<Device, Error>) -> Void)
    func startHeartbeat()
}
