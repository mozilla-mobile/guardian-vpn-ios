//
//  NetworkRequesting
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import Foundation

protocol NetworkRequesting {
    static func initiateUserLogin(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void)
    static func accountInfo(token: String, completion: @escaping (Result<User, Error>) -> Void)
    static func verify(urlString: String, completion: @escaping (Result<VerifyResponse, Error>) -> Void)
    static func availableServers(with token: String, completion: @escaping (Result<[VPNCountry], Error>) -> Void)
    static func addDevice(with token: String, body: [String: Any], completion: @escaping (Result<Device, Error>) -> Void)
    static func removeDevice(with token: String, deviceKey: String, completion: @escaping (Result<Data, Error>) -> Void)
}
