// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit

// TODO: This class is getting too big. We need to break it up among it's responsibilities.

class AccountManager: AccountManaging {
    static let sharedManager = AccountManager()
    let credentialsStore = CredentialsStore.sharedStore // Should this be on the protocol?
    private(set) var account: Account?

    private init() {
        //
    }

    func set(with account: Account) {
        self.account = account
        addDevice { _ in } // TODO: Remove this once login / dev management is done
        retrieveVPNServers { _ in }
    }

    func login(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void) {
        GuardianAPI.initiateUserLogin(completion: completion)
    }

    func verify(url: URL, completion: @escaping (Result<VerifyResponse, Error>) -> Void) {
        GuardianAPI.verify(urlString: url.absoluteString) { result in
            completion(result.map { verifyResponse in
                verifyResponse.saveToUserDefaults()
                return verifyResponse
            })
        }
    }

    func retrieveUser(completion: @escaping (Result<User, Error>) -> Void) {
        guard let account = account else {
            completion(Result.failure(GuardianFailReason.emptyToken))
            return // TODO: Handle this case?
        }
        GuardianAPI.accountInfo(token: account.token) { result in
            completion(result.map { user in
                account.user = user
                return user
            })
        }
    }

    func retrieveVPNServers(completion: @escaping (Result<[VPNCountry], Error>) -> Void) {
        guard let account = account else {
            completion(Result.failure(GuardianFailReason.emptyToken))
            return // TODO: Handle this case?
        }
        GuardianAPI.availableServers(with: account.token) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                do {
                    self.account?.availableServers = try result.get()
                } catch {
                    print(error)
                }
            }
        }
    }

    func addDevice(completion: @escaping (Result<Device, Error>) -> Void) {
        guard let account = account else {
            completion(Result.failure(GuardianFailReason.emptyToken))
            return // TODO: Handle this case?
        }

        let deviceBody: [String: Any] = ["name": UIDevice.current.name,
                                         "pubkey": credentialsStore.deviceKeys.devicePublicKey.base64Key() ?? ""]

        do {
            let body = try JSONSerialization.data(withJSONObject: deviceBody)
            GuardianAPI.addDevice(with: account.token, body: body) { [weak self] result in
                completion(result.map { device in
                    self?.account?.currentDevice = device
                    device.saveToUserDefaults()
                    return device
                })
            }
        } catch {
            completion(Result.failure(GuardianFailReason.couldNotCreateBody))
        }
    }
}
