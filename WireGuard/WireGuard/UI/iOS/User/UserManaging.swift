// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

protocol UserManaging {
    var loginCheckPointModel: LoginCheckpointModel? { get }
    var currentDevice: Device? { get }

    func retrieveUserLoginInformation(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void)
    func verifyAfterLogin(completion: @escaping (Result<User, Error>) -> Void)
    func accountInfo(completion: @escaping (Result<User, Error>) -> Void)
    func retrieveVPNServers(completion: @escaping (Result<[VPNCountry], Error>) -> Void)
    func addDevice(completion: @escaping (Result<Device, Error>) -> Void)
}
