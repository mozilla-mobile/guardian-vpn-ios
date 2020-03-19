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
    private(set) var selectedCity: VPNCity?
    private let disposeBag = DisposeBag()
    //make private
    let accountStore = AccountStore()

    init() {
        subscribeToExpiredSubscriptionNotification()
    }

    func login(with verification: VerifyResponse, completion: @escaping (Result<Void, Error>) -> Void) {
        Credentials.removeAll()
        let credentials = Credentials(with: verification)
        let account = Account(credentials: credentials,
                              user: verification.user,
                              accountStore: accountStore)

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
                self.selectedCity = self.accountStore.readValue(forKey: .selectedCity) ?? self.availableServers?.getRandomUSCity()
                DependencyFactory.sharedFactory.heartbeatMonitor.start()
                completion(.success(()))
            case (.some(let error), _):
                if let error = error as? GuardianAPIError, error == GuardianAPIError.maxDevicesReached {
                    credentials.saveAll()
                    self.account = account
                    self.selectedCity = self.accountStore.readValue(forKey: .selectedCity) ?? self.availableServers?.getRandomUSCity()
                    DependencyFactory.sharedFactory.heartbeatMonitor.start()
                }
                completion(.failure(error))
            case (.none, .some(let error)):
                if let device = account.currentDevice {
                    account.remove(device: device)
                        .subscribe { _ in }
                        .disposed(by: self.disposeBag)
                }
                completion(.failure(error))
            }
        }
    }

    func loginWithStoredCredentials() -> Bool {
        guard let credentials = Credentials.fetchAll(),
            let currentDevice: Device = accountStore.readValue(forKey: .device),
            let user: User = accountStore.readValue(forKey: .user),
            let serverList: [VPNCountry] = accountStore.readValue(forKey: .vpnServers) else {
                return false
        }

        self.account = Account(credentials: credentials,
                               user: user,
                               currentDevice: currentDevice,
                               accountStore: accountStore)

        self.availableServers = serverList
        self.selectedCity = accountStore.readValue(forKey: .selectedCity) ?? self.availableServers?.getRandomUSCity()
        DependencyFactory.sharedFactory.heartbeatMonitor.start()

        return true
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
                Logger.global?.log(message: "Logout Error: \(error)")
                completion(.failure(error))
            }
        }
    }

    func retrieveVPNServers(with token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        GuardianAPI.availableServers(with: token) { result in
            switch result {
            case .success (let servers):
                self.availableServers = servers
                self.accountStore.saveValue(forKey: .vpnServers, value: servers)
                completion(.success(()))
            case .failure(let error):
                Logger.global?.log(message: "Server list retrieval Error: \(error)")
                completion(.failure(error))
            }
        }
    }

    private func resetAccount() {
        DependencyFactory.sharedFactory.tunnelManager.stopAndRemove()
        DependencyFactory.sharedFactory.heartbeatMonitor.stop()
        DependencyFactory.sharedFactory.connectionHealthMonitor.stop()

        account = nil
        availableServers = nil
        selectedCity = nil

        accountStore.removeAll()
        Credentials.removeAll()

        Logger.global?.log(message: "Reset account")
    }

    func updateSelectedCity(with newCity: VPNCity) {
        self.selectedCity = newCity
        self.accountStore.saveValue(forKey: .selectedCity, value: newCity)
    }

    private func subscribeToExpiredSubscriptionNotification() {
        //swiftlint:disable:next trailing_closure
        NotificationCenter.default.rx
            .notification(Notification.Name.expiredSubscriptionNotification)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.resetAccount()
                self?.navigate(to: .landing)
        }).disposed(by: disposeBag)
    }
}
