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

import RxSwift
import RxCocoa

class AccountManager: AccountManaging, Navigating {
    static var navigableItem: NavigableItem = .account

    private(set) var account: Account? {
        didSet {
            _isSubscriptionActive.accept(account?.isSubscriptionActive ?? false)
        }
    }
    private(set) var availableServers: [VPNCountry] = []
    private(set) var selectedCity: VPNCity? {
        didSet {
            if let selectedCity = selectedCity {
                self.accountStore.save(selectedCity: selectedCity)
            }
        }
    }
    private let disposeBag = DisposeBag()
    private let guardianAPI: GuardianAPI
    private let accountStore: AccountStoring
    private let deviceName: String
    private var _isSubscriptionActive: BehaviorRelay<Bool>

    var isSubscriptionActive: Observable<Bool> {
        return _isSubscriptionActive.asObservable()
    }

    init(guardianAPI: GuardianAPI, accountStore: AccountStoring, deviceName: String) {
        self.guardianAPI = guardianAPI
        self.accountStore = accountStore
        self.deviceName = deviceName

        _isSubscriptionActive = BehaviorRelay<Bool>(value: false)

        subscribeToExpiredSubscriptionNotification()
    }

    // MARK: - Authentication
    func login(with verification: VerifyResponse, completion: @escaping (Result<Void, LoginError>) -> Void) {
        let credentials = Credentials(with: verification)
        account = Account(credentials: credentials,
                          user: verification.user)

        let dispatchGroup = DispatchGroup()
        var addDeviceError: DeviceManagementError?
        var retrieveServersError: Error?

        if account?.isSubscriptionActive == true {
            dispatchGroup.enter()
            addCurrentDevice { result in
                if case .failure(let error) = result {
                    addDeviceError = error
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.enter()
        retrieveVPNServers(with: account!.token) { result in
            if case .failure(let error) = result {
                retrieveServersError = error
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            switch (addDeviceError, retrieveServersError) {
            case (.none, .none):
                self.accountStore.save(credentials: credentials)
                self.accountStore.save(user: verification.user)
                self.selectedCity = self.accountStore.getSelectedCity() ?? self.availableServers.getRandomUSCity()
                DependencyManager.shared.heartbeatMonitor.start()
                completion(.success(()))
            case (.some(let error), _):
                guard error != .maxDevicesReached else {
                    self.accountStore.save(credentials: credentials)
                    self.accountStore.save(user: verification.user)
                    self.selectedCity = self.accountStore.getSelectedCity() ?? self.availableServers.getRandomUSCity()
                    DependencyManager.shared.heartbeatMonitor.start()
                    completion(.failure(.maxDevicesReached))
                    return
                }
                completion(.failure(.couldNotAddDevice))
            case (.none, .some):
                if let device = self.account?.currentDevice {
                    self.remove(device: device)
                        .subscribe { _ in }
                        .disposed(by: self.disposeBag)
                }
                completion(.failure(.couldNotGetServers))
            }
        }
    }

    func loginWithStoredCredentials() -> Bool {
        guard let credentials = accountStore.getCredentials(),
            let user: User = accountStore.getUser() else {
            return false
        }

        self.account = Account(credentials: credentials,
                               user: user,
                               currentDevice: accountStore.getCurrentDevice())

        self.availableServers = accountStore.getVpnServers()
        self.selectedCity = accountStore.getSelectedCity() ?? self.availableServers.getRandomUSCity()
        DependencyManager.shared.heartbeatMonitor.start()

        return true
    }

    func logout(completion: @escaping (Result<Void, GuardianAPIError>) -> Void) {
        if account?.isSubscriptionActive == true,
            let device = account?.currentDevice,
            let token = account?.token {
            guardianAPI.removeDevice(with: token, deviceKey: device.publicKey) { [weak self] result in
                self?.resetAccount()
                switch result {
                case .success:
                    self?.resetAccount()
                    completion(.success(()))
                case .failure(let error):
                    Logger.global?.log(message: "Logout Error: \(error)")
                    completion(.failure(error))
                }
            }
        } else {
            resetAccount()
            completion(.success(()))
        }
    }

    // MARK: - Account Operations
    func addCurrentDevice(completion: @escaping (Result<Void, DeviceManagementError>) -> Void) {
        guard let account = account else {
            completion(.failure(.couldNotAddDevice))
            return
        }
        guard let devicePublicKey = account.credentials.deviceKeys.publicKey.base64Key() else {
            completion(.failure(.noPublicKey))
            return
        }

        guard !account.hasDeviceBeenAdded else {
            completion(.success(()))
            return
        }

        let body: [String: Any] = ["name": deviceName,
                                   "pubkey": devicePublicKey]

        guardianAPI.addDevice(with: account.credentials.verificationToken, body: body) { [weak self] result in
            guard let self = self else {
                completion(.failure(.couldNotAddDevice))
                return
            }
            switch result {
            case .success(let device):
                self.account?.currentDevice = device
                self.accountStore.save(currentDevice: device)
                self.getUser { _ in //TODO: Change this to make get devices call when the web servive endpoint is ready
                    completion(.success(()))
                }
            case .failure(let error):
                Logger.global?.log(message: "Add Device Error: \(error)")
                let deviceError: DeviceManagementError = error == .maxDevicesReached ? .maxDevicesReached : .couldNotAddDevice
                completion(.failure(deviceError))
            }
        }
    }

    func getUser(completion: @escaping (Result<Void, AccountError>) -> Void) {
        guard let account = account else {
            completion(Result.failure(.noAccountFound))
            return
        }

        guardianAPI.accountInfo(token: account.credentials.verificationToken) { [weak self] result in
            guard let self = self else {
                completion(.failure(.noAccountFound))
                return
            }
            switch result {
            case .success(let user):
                self.account?.user = user
                self.accountStore.save(user: user)
                completion(.success(()))
            case .failure(let error):
                Logger.global?.log(message: "Account Error: \(error)")
                completion(.failure(error.getAccountError()))
            }
        }
    }

    func remove(device: Device) -> Single<Void> {
        return Single<Void>.create { [weak self] resolver in
            guard let self = self,
                let verificationToken = self.account?.credentials.verificationToken else {
                resolver(.error(DeviceManagementError.couldNotRemoveDevice(device)))
                return Disposables.create()
            }

            self.account?.user.markIsBeingRemoved(for: device)
            self.guardianAPI.removeDevice(with: verificationToken, deviceKey: device.publicKey) { result in
                switch result {
                case .success:
                    self.account?.user.remove(device: device)
                    resolver(.success(()))
                case .failure(let error):
                    self.account?.user.failedRemoval(of: device)
                    Logger.global?.log(message: "Remove Device Error: \(error)")
                    resolver(.error(DeviceManagementError.couldNotRemoveDevice(device)))
                }
            }
            return Disposables.create()
        }
    }

    // MARK: - VPN Server Operations

    func retrieveVPNServers(with token: String, completion: @escaping (Result<Void, GuardianAPIError>) -> Void) {
        guardianAPI.availableServers(with: token) { result in
            switch result {
            case .success (let servers):
                self.availableServers = servers
                self.accountStore.save(vpnServers: servers)
                completion(.success(()))
            case .failure(let error):
                Logger.global?.log(message: "Server list retrieval Error: \(error)")
                completion(.failure(error))
            }
        }
    }

    private func resetAccount() {
        DependencyManager.shared.tunnelManager.stopAndRemove()
        DependencyManager.shared.heartbeatMonitor.stop()
        DependencyManager.shared.connectionHealthMonitor.stop()

        account = nil
        availableServers = []
        selectedCity = nil

        accountStore.removeAll()

        Logger.global?.log(message: "Reset account")
    }

    func updateSelectedCity(with newCity: VPNCity) {
        self.selectedCity = newCity
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
