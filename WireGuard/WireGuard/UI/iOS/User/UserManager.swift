// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation
import UIKit

// TODO: This class is getting too big. We need to break it up among it's responsibilities.

class UserManager: UserManaging {
    static let sharedManager = UserManager()
    let credentialsStore = CredentialsStore.sharedStore

    var loginCheckPointModel: LoginCheckpointModel? {
        return loginModel
    }

    var currentDevice: Device? {
        return device
    }

    private var token: String?
    private(set) var currentUser: User? // temporary?
    private(set) var loginModel: LoginCheckpointModel? // temporary?
    private(set) var device: Device? // temporary

    //move these somewhere else
    func setup(with verifyResponse: VerifyResponse, device: Device) {
        self.device = device
        token = verifyResponse.token
        currentUser = verifyResponse.user
    }

    func retrieveUserLoginInformation(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void) {
        GuardianAPI.initiateUserLogin { [weak self] result in
            completion(result.map { loginCheckPointModel in
                self?.loginModel = loginCheckPointModel
                return loginCheckPointModel
            })
        }
    }

    func verifyAfterLogin(completion: @escaping (Result<User, Error>) -> Void) {
        guard let loginCheckPointModel = loginCheckPointModel else {
            completion(Result.failure(GuardianFailReason.loginError))
            return
        }
        GuardianAPI.verify(urlString: loginCheckPointModel.verificationUrl.absoluteString) { [weak self] result in
            completion(result.map { verifyResponse in
                self?.save(with: verifyResponse)
                self?.token = verifyResponse.token
                return verifyResponse.user
            })
        }
    }

    func accountInfo(completion: @escaping (Result<User, Error>) -> Void) {
        guard let token = token else {
            completion(Result.failure(GuardianFailReason.emptyToken))
            return // TODO: Handle this case?
        }
        GuardianAPI.accountInfo(token: token) { [weak self] result in
            completion(result.map { user in
                self?.currentUser = user
                return user
            })
        }
    }

    func retrieveVPNServers(completion: @escaping (Result<[VPNCountry], Error>) -> Void) {
        guard let token = token else {
            completion(Result.failure(GuardianFailReason.emptyToken))
            return // TODO: Handle this case?
        }
        GuardianAPI.availableServers(with: token, completion: completion)
    }

    func addDevice(completion: @escaping (Result<Device, Error>) -> Void) {
        guard let token = token else {
            completion(Result.failure(GuardianFailReason.emptyToken))
            return // TODO: Handle this case?
        }

        let deviceBody: [String: Any] = ["name": UIDevice.current.name, "pubkey":  credentialsStore.deviceKeys.devicePublicKey.base64Key() ?? ""]

        do {
            let body = try JSONSerialization.data(withJSONObject: deviceBody)
            GuardianAPI.addDevice(with: token, body: body) { [weak self] result in
                completion(result.map { device in
                    self?.device = device
                    device.saveToUserDefaults()
                    return device
                })
            }
        } catch {
            completion(Result.failure(GuardianFailReason.couldNotCreateBody))
        }
    }

    // MARK: User Defaults
    func save<T: UserDefaulting>(with response: T) {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(response)
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: T.userDefaultsKey)
            defaults.synchronize()

        } catch {
            print(error) // TODO: Handle this
        }
    }

    // TODO: Make these 2 functions generic.
    //    func fetchDevice() -> Bool {
    //        if let decoded = UserDefaults.standard.object(forKey: Device.userDefaultsKey) as? Data {
    //            let decoder = JSONDecoder()
//            if let response = try? decoder.decode(Device.self, from: decoded) {
//                currentDevice = response
//                return true
//            }
//            return false
//        } else {
//            return false
//        }
//    }
//
//    func fetchSavedToken() -> Bool {
//        if let decoded = UserDefaults.standard.object(forKey: VerifyResponse.userDefaultsKey) as? Data {
//            let decoder = JSONDecoder()
//            if let response = try? decoder.decode(VerifyResponse.self, from: decoded) {
//                token = response.token
//                currentUser = response.user
//                return true
//            }
//            return false
//        } else {
//            return false
//        }
//    }
}
