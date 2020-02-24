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

import Foundation
import RxSwift

class AccountManager: AccountManaging, Navigating {
    static var navigableItem: NavigableItem = .account
    static let sharedManager = AccountManager()

    private(set) var account: Account?
    private(set) var availableServers: [VPNCountry]?
    private let disposeBag = DisposeBag()

    func login(with verification: VerifyResponse, completion: @escaping (Result<Void, Error>) -> Void) {
        Credentials.removeAll()
        let credentials = Credentials(with: verification)
        let account = Account(credentials: credentials, user: verification.user)

        let dispatchGroup = DispatchGroup()
        var addDeviceError: Error?
        var retrieveServersError: Error?

        dispatchGroup.enter()
        account.addCurrentDevice { result in
            if case .failure(let error) = result {
                addDeviceError = error
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        retrieveVPNServers(with: account.token) { result in
            if case .failure(let error) = result {
                retrieveServersError = error
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            switch (addDeviceError, retrieveServersError) {
            case (.none, .none):
                credentials.saveAll()
                self.account = account
                self.subscribeToHeartbeat()
                DependencyFactory.sharedFactory.heartbeatMonitor.start()
                completion(.success(()))
            case (.some(let error), _):
                if let error = error as? GuardianAPIError, error == GuardianAPIError.maxDevicesReached {
                    credentials.saveAll()
                    self.account = account
                    self.subscribeToHeartbeat()
                    DependencyFactory.sharedFactory.heartbeatMonitor.start()
                }
                completion(.failure(error))
            case (.none, .some(let error)):
                if let device = account.currentDevice {
                    _ = account.remove(device: device)
                }
                completion(.failure(error))
            }
        }
    }

    func loginWithStoredCredentials(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let credentials = Credentials.fetchAll(), let currentDevice = Device.fetchFromUserDefaults() else {
            completion(.failure(GuardianError.needToLogin))
            return
        }

        let account = Account(credentials: credentials, currentDevice: currentDevice)

        let dispatchGroup = DispatchGroup()
        var setUserError: Error?
        var retrieveServersError: Error?

        dispatchGroup.enter()
        account.getUser { result in
            if case .failure(let error) = result {
                setUserError = error
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        retrieveVPNServers(with: account.token) { result in
            if case .failure(let error) = result {
                retrieveServersError = error
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            switch (setUserError, retrieveServersError) {
            case (.none, .none):
                credentials.saveAll()
                self.account = account
                self.subscribeToHeartbeat()
                DependencyFactory.sharedFactory.heartbeatMonitor.start()
                completion(.success(()))
            case (let userError, let serverError):
                let error = userError ?? serverError
                completion(.failure(error ?? GuardianAPIError.unknown))
            }
        }
    }

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let device = account?.currentDevice, let token = account?.token else {
            completion(Result.failure(GuardianError.needToLogin))
            return
        }
        GuardianAPI.removeDevice(with: token, deviceKey: device.publicKey) { result in
            switch result {
            case .success:
                self.resetAccount()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func retrieveVPNServers(with token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        GuardianAPI.availableServers(with: token) { result in
            switch result {
            case .success (let servers):
                self.availableServers = servers
                self.availableServers?.saveToUserDefaults()
                if !VPNCity.existsInDefaults, let randomUSServer = servers.getRandomUSServer() {
                    randomUSServer.saveToUserDefaults()
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func resetAccount() {
        DependencyFactory.sharedFactory.heartbeatMonitor.stop()
        DependencyFactory.sharedFactory.tunnelManager.stopAndRemove()
        Credentials.removeAll()
        Device.removeFromUserDefaults()
        account = nil
        availableServers = nil
    }

    private func subscribeToHeartbeat() {
        DependencyFactory.sharedFactory.heartbeatMonitor
            .subscriptionExpiredEvent
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] in
                self?.resetAccount()
                self?.navigate(to: .landing)
        }.disposed(by: disposeBag)
    }
}
