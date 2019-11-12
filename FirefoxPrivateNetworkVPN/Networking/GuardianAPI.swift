//
//  GuardianAPI
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

class GuardianAPI: NetworkRequesting {

    static func initiateUserLogin(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void) {
        let urlRequest = GuardianURLRequestBuilder.urlRequest(request: .login, type: .POST)
        NetworkLayer.fire(urlRequest: urlRequest) { result in
            completion(result
                .unwrapSuccess()
                .flatMap { $0.convert(to: LoginCheckpointModel.self) }
            )
        }
    }

    static func accountInfo(token: String, completion: @escaping (Result<User, Error>) -> Void) {
        let urlRequest = GuardianURLRequestBuilder.urlRequest(request: .account, type: .GET, httpHeaderParams: headers(with: token))
        NetworkLayer.fire(urlRequest: urlRequest) { result in
            completion(result
                .unwrapSuccess()
                .flatMap { $0.convert(to: User.self) }
            )
        }
    }

    static func verify(urlString: String, completion: @escaping (Result<VerifyResponse, Error>) -> Void) {
        let urlRequest = GuardianURLRequestBuilder.urlRequest(fullUrlString: urlString, type: .GET)
        NetworkLayer.fire(urlRequest: urlRequest) { result in
            completion(result
                .unwrapSuccess()
                .flatMap { $0.convert(to: VerifyResponse.self) }
            )
        }
    }

    static func availableServers(with token: String, completion: @escaping (Result<[VPNCountry], Error>) -> Void) {
        let urlRequest = GuardianURLRequestBuilder.urlRequest(request: .retrieveServers, type: .GET, httpHeaderParams: headers(with: token))
        NetworkLayer.fire(urlRequest: urlRequest) { result in
            completion(result
                .unwrapSuccess()
                .flatMap { $0.convert(to: [String: [VPNCountry]].self) }
                .map { $0["countries"]! }
            )
        }
    }

    static func addDevice(with token: String, body: [String: Any], completion: @escaping (Result<Device, Error>) -> Void) {
        guard let data = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(GuardianFailReason.couldNotCreateBody))
            return
        }

        let urlRequest = GuardianURLRequestBuilder.urlRequest(request: .addDevice, type: .POST, httpHeaderParams: headers(with: token), body: data)
        NetworkLayer.fire(urlRequest: urlRequest) { result in
            completion(result
                .unwrapSuccess()
                .flatMap { $0.convert(to: Device.self) }
            )
        }
    }

    static func removeDevice(with token: String, deviceKey: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let encodedKey = deviceKey.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion(.failure(GuardianFailReason.emptyToken))
            return
        }

        let urlRequest = GuardianURLRequestBuilder.urlRequest(request: .removeDevice(encodedKey), type: .DELETE, httpHeaderParams: headers(with: token))

        NetworkLayer.fire(urlRequest: urlRequest) { result in
            switch result {
            case .success:
                completion(.success(()))
            case.failure(let error):
                completion(.failure(error))
            }
        }
    }

    private static func headers(with token: String) -> [String: String] {
        return ["Authorization": "Bearer \(token)",
                "Content-Type": "application/json"]
    }
}
