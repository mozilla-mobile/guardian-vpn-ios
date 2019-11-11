//
//  NetworkRequesting
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

protocol NetworkRequesting {
    static func initiateUserLogin(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void)
    static func accountInfo(token: String, completion: @escaping (Result<User, Error>) -> Void)
    static func verify(urlString: String, completion: @escaping (Result<VerifyResponse, Error>) -> Void)
    static func availableServers(with token: String, completion: @escaping (Result<[VPNCountry], Error>) -> Void)
    static func addDevice(with token: String, body: [String: Any], completion: @escaping (Result<Device, GuardianAPIError>) -> Void)
    static func removeDevice(with token: String, deviceKey: String, completion: @escaping (Result<Void, Error>) -> Void)
}
