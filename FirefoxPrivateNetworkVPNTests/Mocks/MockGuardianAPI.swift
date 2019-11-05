//
//  MockGuardianAPI
//  FirefoxPrivateNetworkVPNTests
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
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

    static func addDevice(with token: String, body: [String : Any], completion: @escaping (Result<Device, Error>) -> Void) {
        apiCallObservable.onNext(())
        guard let jsonUserURL = Bundle.main.url(forResource: "device", withExtension: "json"),
            let device = try? JSONDecoder().decode(Device.self, from: Data(contentsOf: jsonUserURL))
            else { return }
        completion(Result.success(device))
    }

    static func removeDevice(with deviceKey: String, completion: @escaping (Result<Data, Error>) -> Void) {
        apiCallObservable.onNext(())
        completion(Result.success(Data()))
    }
}
