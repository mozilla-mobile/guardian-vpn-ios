//
//  Account
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

class Account {
    private var credentials: Credentials
    private(set) var currentDevice: Device?
    private(set) var user: User
    private let accountStore: AccountStore

    var token: String {
        return credentials.verificationToken
    }

    var publicKey: Data {
        return credentials.deviceKeys.publicKey
    }

    var privateKey: Data {
        return credentials.deviceKeys.privateKey
    }

    var hasDeviceBeenAdded: Bool {
        return currentDevice != nil
    }

    init(credentials: Credentials, user: User, currentDevice: Device? = nil, accountStore: AccountStore) {
        self.accountStore = accountStore
        self.credentials = credentials
        self.user = user
        self.currentDevice = currentDevice
    }

    func addCurrentDevice(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let devicePublicKey = credentials.deviceKeys.publicKey.base64Key() else {
            completion(Result.failure(GuardianError.couldNotEncodeData))
            return
        }
        let body: [String: Any] = ["name": UIDevice.current.name,
                                   "pubkey": devicePublicKey]

        guard !hasDeviceBeenAdded else {
            completion(.success(()))
            return
        }

        GuardianAPI.addDevice(with: credentials.verificationToken, body: body) { [weak self] result in
            guard let self = self else {
                completion(.failure(GuardianError.deallocated))
                return
            }
            switch result {
            case .success(let device):
                self.currentDevice = device
                self.accountStore.saveValue(forKey: .device, value: device)

                self.getUser { _ in //TODO: Change this to make get devices call when its available
                    completion(.success(()))
                }
            case .failure(let error):
                Logger.global?.log(message: "Add Device Error: \(error)")
                completion(.failure(error))
            }
        }
    }

    func getUser(completion: @escaping (Result<Void, Error>) -> Void) {
        GuardianAPI.accountInfo(token: credentials.verificationToken) { [weak self] result in
            guard let self = self else {
                completion(.failure(GuardianError.deallocated))
                return
            }
            switch result {
            case .success(let user):
                self.user = user
                self.accountStore.saveValue(forKey: .user, value: user)
                completion(.success(()))
            case .failure(let error):
                Logger.global?.log(message: "Account Error: \(error)")
                completion(.failure(error))
            }
        }
    }

    func remove(device: Device) -> Single<Void> {
        return Single<Void>.create { [weak self] resolver in
            guard let self = self else {
                resolver(.error(GuardianError.deallocated))
                return Disposables.create()
            }

            self.user.markIsBeingRemoved(for: device)
            GuardianAPI.removeDevice(with: self.credentials.verificationToken, deviceKey: device.publicKey) { result in
                switch result {
                case .success:
                    self.user.remove(device: device)
                    resolver(.success(()))
                case .failure(let error):
                    self.user.failedRemoval(of: device)
                    Logger.global?.log(message: "Remove Device Error: \(error)")
                    resolver(.error(GuardianError.couldNotRemoveDevice(device)))
                }
            }
            return Disposables.create()
        }
    }
}
