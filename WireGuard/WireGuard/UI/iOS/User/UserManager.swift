// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

class UserManager {
    static let sharedManager = UserManager()
    private let verifyResponseUserDefaultsKey = "verifyResponseUserDefaults"
    private let currentUserUserDefaultsKey = "currentUserUserDefaults"

    private var token: String?
    private(set) var currentUser: User? // temporary?
    private(set) var loginCheckPointModel: LoginCheckpointModel? // temporary?

    func retrieveUserLoginInformation(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void) {
        GuardianAPI.initiateUserLogin { [weak self] result in
            completion(result.map { loginCheckPointModel in
                self?.loginCheckPointModel = loginCheckPointModel
                return loginCheckPointModel
            })
        }
    }

    func verify(with loginCheckPointModel: LoginCheckpointModel,
                completion: @escaping (Result<User, Error>) -> Void) {
        GuardianAPI.verify(urlString: loginCheckPointModel.verificationUrl.absoluteString) { [weak self] result in
            completion(result.map { verifyResponse in
                self?.save(with: verifyResponse)
                self?.token = verifyResponse.token
                self?.currentUser = verifyResponse.user
                return verifyResponse.user
            })
        }
    }

    func verify(with token: String, completion: @escaping (Result<User, Error>) -> Void) {
        GuardianAPI.verify(token: token) { [weak self] result in
            completion(result.map { verifyResponse in
                self?.save(with: verifyResponse)
                self?.token = verifyResponse.token
                self?.currentUser = verifyResponse.user
                return verifyResponse.user
            })
        }
    }

    func retrieveVPNServers(completion: @escaping (Result<[VPNCountry], Error>) -> Void) {
        guard let token = token else {
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
        } else {
            print("blahhh") // TODO: Handle this
        }
    }

    func fetchSavedUserAndToken() -> Bool {
        return false
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
