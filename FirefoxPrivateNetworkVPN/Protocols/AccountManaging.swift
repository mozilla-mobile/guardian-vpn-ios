//
//  AccountManaging
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import Foundation
import RxSwift

protocol AccountManaging {
    var user: User? { get }
    var token: String? { get }
    var currentDevice: Device? { get }
    var availableServers: [VPNCountry]? { get }
    var heartbeatFailedEvent: PublishSubject<Void> { get }

    func login(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void)
    func logout(completion: @escaping (Result<Void, Error>) -> Void)
    func setupFromAppLaunch(completion: @escaping (Result<Void, Error>) -> Void)
    func setupFromVerify(url: URL, completion: @escaping (Result<Void, Error>) -> Void)
    func finishSetupFromVerify(completion: @escaping (Result<Void, Error>) -> Void)
    func startHeartbeat()
    func countryCodeForCity(_ city: String) -> String?
}
