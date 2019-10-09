// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

// TODO: This class is getting too big. We need to break it up among it's responsibilities.

class AccountManager: AccountManaging {
    static let sharedManager = AccountManager()

    var loginCheckPointModel: LoginCheckpointModel? {
        return loginModel
    }
    
    private var account = Account()

    private var token: String?
    private(set) var currentUser: User? // temporary?
    private(set) var loginModel: LoginCheckpointModel? // temporary?
    private(set) var currentDevice: Device? // temporary

    //move these somewhere else
    func setupAccount(with verifyResponse: VerifyResponse, device: Device) {
        account.currentDevice = device
        account.token = verifyResponse.token
        account.user = verifyResponse.user
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
                verifyResponse.saveToUserDefaults()
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
        GuardianAPI.addDevice(with: token) { [weak self] result in
            completion(result.map { device in
                self?.currentDevice = device
                device.saveToUserDefaults()
                return device
            })
        }
    }

    // MARK: User Defaults
//    func save<T: UserDefaulting>(with response: T) {
//        let encoder = JSONEncoder()
//        do {
//            let encoded = try encoder.encode(response)
//            let defaults = UserDefaults.standard
//            defaults.set(encoded, forKey: T.userDefaultsKey)
//            defaults.synchronize()
//
//        } catch {
//            print(error) // TODO: Handle this
//        }
//    }

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
