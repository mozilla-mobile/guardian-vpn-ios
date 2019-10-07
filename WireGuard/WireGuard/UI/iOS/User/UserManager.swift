// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

class UserManager: UserManaging {
    static let sharedManager = UserManager()
    private let verifyResponseUserDefaultsKey = "verifyResponseUserDefaults"
    private let currentUserUserDefaultsKey = "currentUserUserDefaults"

    var loginCheckPointModel: LoginCheckpointModel? {
        return loginModel
    }

    private var token: String?
    private(set) var currentUser: User? // temporary?
    private(set) var loginModel: LoginCheckpointModel? // temporary?

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

    // MARK: User Defaults
    func save(with verifyResponse: VerifyResponse) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(verifyResponse) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: verifyResponseUserDefaultsKey)
            defaults.synchronize()
            token = verifyResponse.token
        } else {
            print("blahhh") // TODO: Handle this
        }
    }

    func fetchSavedToken() -> Bool {
        if let decoded = UserDefaults.standard.object(forKey: verifyResponseUserDefaultsKey) as? Data {
            let decoder = JSONDecoder()
            if let response = try? decoder.decode(VerifyResponse.self, from: decoded) {
                token = response.token
                currentUser = response.user
                return true
            }
            return false
        } else {
            return false
        }
    }
}
