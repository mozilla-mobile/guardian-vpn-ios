// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

protocol UserManagerProtocol {
    var loginCheckPointModel: LoginCheckpointModel? { get }

    func retrieveUserLoginInformation(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void)
    func verifyAfterLogin(completion: @escaping (Result<User, Error>) -> Void)
    func verify(with token: String, completion: @escaping (Result<User, Error>) -> Void)
    func retrieveVPNServers(completion: @escaping (Result<[VPNCountry], Error>) -> Void)
}
