//
//  AccountManager
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import UIKit
import RxSwift

class Account: AccountManaging {
    private(set) var credentials: Credentials
    private(set) var user: User?
    private(set) var availableServers: [VPNCountry]?
    private(set) var heartbeatFailedEvent = PublishSubject<Void>()
    private(set) var currentDevice: Device?

//    {
//        didSet {
//            if let currentDevice = currentDevice {
//                currentDevice.saveToUserDefaults()
//            } else {
//                Device.removeFromUserDefaults()
//            }
//        }
//    }

    init(with verification: VerifyResponse) {
        user = verification.user
        credentials = Credentials(with: verification)
    }

    init(with userDefaults: Credentials) {
        credentials = userDefaults
    }

    func finishSetup(completion: @escaping (Result<Void, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var error: Error?

        if currentDevice == nil {
            dispatchGroup.enter()
            addDevice { _ in
                //handle error - remove currentDevice from defaults (reset device keys) and recreate if necessary
                dispatchGroup.leave()
            }
        }

        if user == nil {
            dispatchGroup.enter()
            retrieveUser { result in
                if case .failure(let retrieveUserError) = result {
                    error = retrieveUserError
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.enter()
        retrieveVPNServers { result in
            if case .failure(let vpnError) = result {
                error = vpnError
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

//    func setupFromAppLaunch(completion: @escaping (Result<Void, Error>) -> Void) {
//        let dispatchGroup = DispatchGroup()
//        var error: Error?
//
//        dispatchGroup.enter()
//        retrieveUser { result in
//            if case .failure(let retrieveUserError) = result {
//                error = retrieveUserError
//            }
//            dispatchGroup.leave()
//        }
//
//        dispatchGroup.enter()
//        retrieveVPNServers { result in
//            if case .failure(let vpnError) = result {
//                error = vpnError
//            }
//            dispatchGroup.leave()
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                completion(.success(()))
//            }
//        }
//    }
//
//    func setupFromVerification(completion: @escaping (Result<Void, Error>) -> Void) {
//        let dispatchGroup = DispatchGroup()
//        var error: Error?
//        dispatchGroup.enter()
//        addDevice { _ in
//            dispatchGroup.leave()
//        }
//
//        dispatchGroup.enter()
//        retrieveVPNServers { result in
//            if case .failure(let vpnError) = result {
//                error = vpnError
//            }
//            dispatchGroup.leave()
//        }
//
//        dispatchGroup.notify(queue: .main) {
//            if let error = error {
//                completion(.failure(error))
//            } else {
//                self.retrieveUser { _ in } //TODO: Change this to make get devices call when its available
//                completion(.success(()))
//            }
//        }
//    }

    func startHeartbeat() {
        _ = Timer(timeInterval: 3600,
                  target: self,
                  selector: #selector(pollUser),
                  userInfo: nil,
                  repeats: true)
    }

    func countryCodeForCity(_ city: String) -> String? {
        return availableServers?
            .first { country -> Bool in
                country.cities.map { $0.name }.contains(city)
            }?.code.lowercased()
    }

    @objc private func pollUser() {
        retrieveUser { _ in }
    }

    private func retrieveUser(completion: @escaping (Result<User, Error>) -> Void) {
        GuardianAPI.accountInfo(token: credentials.verificationToken) { [unowned self] result in
            if case .failure = result {
                self.heartbeatFailedEvent.onNext(())
            }

            completion(result.map { user in
                self.user = user
                return user
            })
        }
    }

    private func retrieveVPNServers(completion: @escaping (Result<[VPNCountry], Error>) -> Void) {
        GuardianAPI.availableServers(with: credentials.verificationToken) { result in
            completion(result.map { [unowned self] servers in
                self.availableServers = servers
                if !VPNCity.existsInDefaults, let randomUSServer = servers.first(where: { $0.code.uppercased() == "US" })?.cities.randomElement() {
                    randomUSServer.saveToUserDefaults()
                }
                return servers
            })
        }
    }

    func addDevice(completion: @escaping (Result<Device, Error>) -> Void) {
        guard let devicePublicKey = credentials.deviceKeys.publicKey.base64Key() else {
            completion(Result.failure(GuardianFailReason.deviceKeyFailure))
            return
        }
        let body: [String: Any] = ["name": UIDevice.current.name,
                                   "pubkey": devicePublicKey]

        GuardianAPI.addDevice(with: credentials.verificationToken, body: body) { [unowned self] result in
            switch result {
            case .success(let device):
                self.currentDevice = device
                self.retrieveUser { _ in } //TODO: Change this to make get devices call when its available
                completion(.success(device))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let device = currentDevice else {
            completion(Result.failure(GuardianFailReason.emptyToken))
            return
        }
        GuardianAPI.removeDevice(with: credentials.verificationToken, deviceKey: device.publicKey) { result in
            switch result {
            case .success:
                Credentials.removeFromUserDefaults()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func removeDevice(with deviceKey: String, completion: @escaping (Result<Void, Error>) -> Void) {
        user?.deviceIsBeingRemoved(with: deviceKey)
        GuardianAPI.removeDevice(with: credentials.verificationToken, deviceKey: deviceKey) { [unowned self] result in
            switch result {
            case .success:
                self.user?.removeDevice(with: deviceKey)
                completion(.success(()))
            case .failure(let error):
                self.user?.deviceFailedRemoval(with: deviceKey)
                completion(.failure(error))
            }
        }
    }
}
