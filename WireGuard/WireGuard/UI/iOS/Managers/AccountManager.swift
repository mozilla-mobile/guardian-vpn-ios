// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit
import RxSwift

class AccountManager: AccountManaging {
    static let sharedManager = AccountManager()
    private let keyStore: KeyStore

    private(set) var user: User?
    private(set) var token: String? // Save to user defaults
    private(set) var currentDevice: Device? // Save to user defaults
    private(set) var availableServers: [VPNCountry]?

    private let tokenUserDefaultsKey = "token"
    public var heartbeatFailedEvent = PublishSubject<Void>()

    private init() {
        keyStore = KeyStore.sharedStore
        token = UserDefaults.standard.string(forKey: tokenUserDefaultsKey)
        currentDevice = Device.fetchFromUserDefaults()
    }

    func login(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void) {
        GuardianAPI.initiateUserLogin(completion: completion)
    }

    func setupFromVerify(url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var error: Error?

        dispatchGroup.enter()
        verify(url: url) { result in
            if case .failure(let verifyError) = result {
                error = verifyError
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        addDevice { result in
            if case .failure(let deviceError) = result {
                error = deviceError
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        retrieveVPNServers { result in
            if case .failure(let vpnError) = result {
                error = vpnError
            }
            dispatchGroup.leave()
        }

        if let error = error {
            completion(.failure(error))
            return
        }

        dispatchGroup.notify(queue: .main) {
            completion(.success(()))
        }
    }

    func setupFromAppLaunch(completion: @escaping (Result<Void, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var error: Error?

        guard let userDefaultsToken = UserDefaults.standard.string(forKey: tokenUserDefaultsKey) else {
            completion(.failure(GuardianFailReason.emptyToken))
            return
        }

        guard let userDefaultsDevice = Device.fetchFromUserDefaults() else {
            completion(.failure(GuardianFailReason.couldNotFetchDevice))
            return
        }

        token = userDefaultsToken
        currentDevice = userDefaultsDevice

        dispatchGroup.enter()
        retrieveUser { result in
            if case .failure(let retrieveUserError) = result {
                error = retrieveUserError
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        retrieveVPNServers { result in
            if case .failure(let vpnError) = result {
                error = vpnError
            }
            dispatchGroup.leave()
        }

        if let error = error {
            completion(.failure(error))
            return
        }

        dispatchGroup.notify(queue: .main) {
            completion(.success(()))
        }
    }

    func startHeartbeat() {
        Timer(timeInterval: 3600,
              target: self,
              selector: #selector(pollUser),
              userInfo: nil,
              repeats: true)
    }

    private func verify(url: URL, completion: @escaping (Result<VerifyResponse, Error>) -> Void) {
        GuardianAPI.verify(urlString: url.absoluteString) { result in
            completion(result.map { [unowned self] verifyResponse in
                UserDefaults.standard.set(verifyResponse.token, forKey: self.tokenUserDefaultsKey)
                self.user = verifyResponse.user
                self.token = verifyResponse.token
                return verifyResponse
            })
        }
    }

    @objc private func pollUser() {
        retrieveUser { _ in }
    }

    func retrieveUser(completion: @escaping (Result<User, Error>) -> Void) {
        guard let token = token else {
            completion(Result.failure(GuardianFailReason.emptyToken))
            return
        }
        GuardianAPI.accountInfo(token: token) { [unowned self] result in
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
        guard let token = token else {
            completion(Result.failure(GuardianFailReason.emptyToken))
            return
        }
        GuardianAPI.availableServers(with: token) { result in
            completion(result.map { [unowned self] servers in
                self.availableServers = servers
                return servers
            })
        }
    }

    private func addDevice(completion: @escaping (Result<Device, Error>) -> Void) {
        guard let token = token else {
            completion(Result.failure(GuardianFailReason.emptyToken))
            return
        }

        let deviceBody: [String: Any] = ["name": UIDevice.current.name,
                                         "pubkey": keyStore.deviceKeys.devicePublicKey.base64Key() ?? ""]

        do {
            let body = try JSONSerialization.data(withJSONObject: deviceBody)
            GuardianAPI.addDevice(with: token, body: body) { [unowned self] result in
                completion(result.map { device in
                    self.currentDevice = device
                    device.saveToUserDefaults()
                    return device
                })
            }
        } catch {
            completion(Result.failure(GuardianFailReason.couldNotCreateBody))
        }
    }
}
