// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit
import RxSwift

class AccountManager: AccountManaging {
    private static let tokenUserDefaultsKey = "token"
    private let keyStore: KeyStore
    private(set) var availableServers: [VPNCountry]?
    private(set) var user: User?

    private(set) var token: String? {
        didSet {
            if let token = token {
                UserDefaults.standard.set(token, forKey: AccountManager.tokenUserDefaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: AccountManager.tokenUserDefaultsKey)
            }
        }
    }

    private(set) var currentDevice: Device? {
        didSet {
            if let currentDevice = currentDevice {
                currentDevice.saveToUserDefaults()
            } else {
                UserDefaults.standard.removeObject(forKey: Device.userDefaultsKey)
            }
        }
    }

    public static let sharedManager = AccountManager()
    public var heartbeatFailedEvent = PublishSubject<Void>()

    private init() {
        keyStore = KeyStore.sharedStore
        token = UserDefaults.standard.string(forKey: AccountManager.tokenUserDefaultsKey)
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

        dispatchGroup.notify(queue: .main) {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func setupFromAppLaunch(completion: @escaping (Result<Void, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var error: Error?

        guard token != nil else {
            completion(.failure(GuardianFailReason.emptyToken))
            return
        }

        guard currentDevice != nil else {
            completion(.failure(GuardianFailReason.couldNotFetchDevice))
            return
        }

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

        dispatchGroup.notify(queue: .main) {
            if let error = error {
                completion(.failure(error))
            } else {
                self.token = nil
                self.currentDevice = nil
                completion(.success(()))
            }
        }
    }

    func startHeartbeat() {
        _ = Timer(timeInterval: 3600,
                  target: self,
                  selector: #selector(pollUser),
                  userInfo: nil,
                  repeats: true)
    }

    private func verify(url: URL, completion: @escaping (Result<VerifyResponse, Error>) -> Void) {
        GuardianAPI.verify(urlString: url.absoluteString) { result in
            completion(result.map { [unowned self] verifyResponse in
                self.user = verifyResponse.user
                self.token = verifyResponse.token
                return verifyResponse
            })
        }
    }

    @objc func pollUser() {
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

    func logoutUser(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let device = currentDevice, let token = token else {
            completion(Result.failure(GuardianFailReason.emptyToken))
            return
        }

        let body: [String: Any] = ["pubkey": token]

        GuardianAPI.removeDevice(with: device.publicKey, body: body) { [unowned self] result in
            completion(result.map { [unowned self] _ in
                self.token = nil
                self.currentDevice = nil
                return
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
                if !VPNCity.existsInDefaults, let randomUSServer = servers.first(where: { $0.code.uppercased() == "US" })?.cities.randomElement() {
                    randomUSServer.saveToUserDefaults()
                }
                return servers
            })
        }
    }

    private func addDevice(completion: @escaping (Result<Device, Error>) -> Void) {
        guard let token = token else {
            completion(Result.failure(GuardianFailReason.emptyToken))
            return
        }

        guard let devicePublicKey = keyStore.deviceKeys.devicePublicKey.base64Key() else {
            completion(Result.failure(GuardianFailReason.keyGenerationFailure))
            return
        }
        let body: [String: Any] = ["name": UIDevice.current.name,
                                   "pubkey": devicePublicKey]

        GuardianAPI.addDevice(with: token, body: body) { [unowned self] result in
            completion(result.map { device in
                self.currentDevice = device
                return device
            })
        }
    }

    func countryCodeForCity(_ city: String) -> String? {
        return availableServers?
            .first { country -> Bool in
                country.cities.map { $0.name }.contains(city)
            }?.code.uppercased()
    }
}
