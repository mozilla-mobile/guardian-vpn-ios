//
//  AccountManager
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import UIKit
import RxSwift

class AccountManager: AccountManaging {
    static let sharedManager: AccountManaging = {
        let instance = AccountManager()
        //
        return instance
    }()

    private(set) var user: User?
    private(set) var availableServers: [VPNCountry]?
    private(set) var heartbeatFailedEvent = PublishSubject<Void>()
    private let tokenUserDefaultsKey = "token"
    private let keyStore: KeyStore

    private(set) var token: String? {
        didSet {
            if let token = token {
                UserDefaults.standard.set(token, forKey: tokenUserDefaultsKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenUserDefaultsKey)
            }
        }
    }
    private(set) var currentDevice: Device? {
        didSet {
            if let currentDevice = currentDevice {
                currentDevice.saveToUserDefaults()
            } else {
                Device.removeFromUserDefaults()
            }
        }
    }

    private init() {
        keyStore = KeyStore.sharedStore
        token = UserDefaults.standard.string(forKey: tokenUserDefaultsKey)
        currentDevice = Device.fetchFromUserDefaults()
    }

    func login(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void) {
        GuardianAPI.initiateUserLogin(completion: completion)
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
                completion(.success(()))
            }
        }
    }

    func setupFromVerify(url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        verify(url: url) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                completion(.success(()))
            }
        }
    }

    func finishSetupFromVerify(completion: @escaping (Result<Void, Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var error: Error?
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
                self.retrieveUser { _ in } //TODO: Change this to make get devices call when its available
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

    func countryCodeForCity(_ city: String) -> String? {
        return availableServers?
            .first { country -> Bool in
                country.cities.map { $0.name }.contains(city)
            }?.code.lowercased()
    }

    @objc private func pollUser() {
        retrieveUser { _ in }
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

    private func retrieveUser(completion: @escaping (Result<User, Error>) -> Void) {
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
            completion(Result.failure(GuardianFailReason.deviceKeyFailure))
            return
        }
        let body: [String: Any] = ["name": UIDevice.current.name,
                                   "pubkey": devicePublicKey]

        GuardianAPI.addDevice(with: token, body: body) { [unowned self] result in
            switch result {
            case .success(let device):
                self.currentDevice = device
                self.retrieveUser { _ in } //TODO: Change this to make get devices call when its available
                completion(.success(device))
            case .failure(let error):
                print(error) //TODO: Map to GuardianFailReasonError
                completion(.failure(GuardianFailReason.no200))
            }
        }
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = token else {
            completion(Result.failure(GuardianFailReason.emptyToken))
            return
        }
        guard let device = currentDevice else {
            completion(Result.failure(GuardianFailReason.emptyToken))
            return
        }
        GuardianAPI.removeDevice(with: token, deviceKey: device.publicKey) { [unowned self] result in
            switch result {
            case .success:
                self.token = nil
                self.currentDevice = nil
                DeviceKeys.removeFromUserDefaults()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func removeDevice(with deviceKey: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = token else {
            completion(Result.failure(GuardianFailReason.emptyToken))
            return
        }
        user?.deviceIsBeingRemoved(with: deviceKey)
        GuardianAPI.removeDevice(with: token, deviceKey: deviceKey) { [unowned self] result in
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
