//
//  MockGuardianAPI
//  FirefoxPrivateNetworkVPNTests
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation
import RxSwift
@testable import Firefox_Private_Network_VPN

class MockGuardianAPI: NetworkRequesting {
    static var apiCallObservable = PublishSubject<Void>()

    static func initiateUserLogin(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void) {
        apiCallObservable.onNext(())
        guard let jsonUserURL = Bundle.main.url(forResource: "loginCheckpointModel", withExtension: "json"),
            let loginCheckpointModel = try? JSONDecoder().decode(LoginCheckpointModel.self, from: Data(contentsOf: jsonUserURL))
            else { return }
        completion(Result.success(loginCheckpointModel))
    }

    static func accountInfo(token: String, completion: @escaping (Result<User, Error>) -> Void) {
        apiCallObservable.onNext(())
        guard let jsonUserURL = Bundle.main.url(forResource: "user", withExtension: "json"),
            let user = try? JSONDecoder().decode(User.self, from: Data(contentsOf: jsonUserURL))
            else { return }
        completion(Result.success(user))
    }

    static func verify(urlString: String, completion: @escaping (Result<VerifyResponse, Error>) -> Void) {
        apiCallObservable.onNext(())
        guard let jsonUserURL = Bundle.main.url(forResource: "verifyResponse", withExtension: "json"),
            let verifyResponse = try? JSONDecoder().decode(VerifyResponse.self, from: Data(contentsOf: jsonUserURL))
            else { return }
        completion(Result.success(verifyResponse))
    }

    static func availableServers(with token: String, completion: @escaping (Result<[VPNCountry], Error>) -> Void) {
        apiCallObservable.onNext(())
        guard let jsonUserURL = Bundle.main.url(forResource: "vpnCountry", withExtension: "json"),
            let vpnCountries = try? JSONDecoder().decode([VPNCountry].self, from: Data(contentsOf: jsonUserURL))
            else { return }
        completion(Result.success(vpnCountries))
    }

    static func addDevice(with token: String, body: [String: Any], completion: @escaping (Result<Device, Error>) -> Void) {
        apiCallObservable.onNext(())
        guard let jsonUserURL = Bundle.main.url(forResource: "device", withExtension: "json"),
            let device = try? JSONDecoder().decode(Device.self, from: Data(contentsOf: jsonUserURL))
            else { return }
        completion(Result.success(device))
    }

    static func removeDevice(with token: String, deviceKey: String, completion: @escaping (Result<Void, Error>) -> Void) {
        apiCallObservable.onNext(())
        completion(Result.success(()))
    }
}
