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

class GuardianAPI: NetworkRequesting {

    private let networkLayer: Networking
    private let userAgentInfo: String

    init(networkLayer: Networking, userAgentInfo: String) {
        self.networkLayer = networkLayer
        self.userAgentInfo = userAgentInfo
    }

    // MARK: -
    func initiateUserLogin(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void) {
        let urlRequest = GuardianURLRequest.urlRequest(request: .login, type: .POST)
        networkLayer.fire(urlRequest: urlRequest) { result in
            DispatchQueue.main.async {
                completion(result.decode(to: LoginCheckpointModel.self))
            }
        }
    }

    func accountInfo(token: String, completion: @escaping (Result<User, Error>) -> Void) {
        let urlRequest = GuardianURLRequest.urlRequest(request: .account, type: .GET, httpHeaderParams: headers(with: token))
        networkLayer.fire(urlRequest: urlRequest) { result in
            DispatchQueue.main.async {
                completion(result.decode(to: User.self))
            }
        }
    }

    func verify(urlString: String, completion: @escaping (Result<VerifyResponse, Error>) -> Void) {
        let urlRequest = GuardianURLRequest.urlRequest(with: urlString, type: .GET)
        networkLayer.fire(urlRequest: urlRequest) { result in
            DispatchQueue.main.async {
                completion(result.decode(to: VerifyResponse.self))
            }
        }
    }

    func availableServers(with token: String, completion: @escaping (Result<[VPNCountry], Error>) -> Void) {
        let urlRequest = GuardianURLRequest.urlRequest(request: .retrieveServers, type: .GET, httpHeaderParams: headers(with: token))
        networkLayer.fire(urlRequest: urlRequest) { result in
            DispatchQueue.main.async {
                completion(result
                    .decode(to: [String: [VPNCountry]].self)
                    .map { $0["countries"]! }
                )
            }
        }
    }

    func addDevice(with token: String, body: [String: Any], completion: @escaping (Result<Device, Error>) -> Void) {
        guard let data = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(GuardianAppError.couldNotCreateBody))
            return
        }

        let urlRequest = GuardianURLRequest.urlRequest(request: .addDevice, type: .POST, httpHeaderParams: headers(with: token), body: data)
        networkLayer.fire(urlRequest: urlRequest) { result in
            DispatchQueue.main.async {
                completion(result.decode(to: Device.self))
            }
        }
    }

    func removeDevice(with token: String, deviceKey: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let encodedKey = deviceKey.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion(.failure(GuardianAppError.couldNotEncodeData))
            return
        }

        let urlRequest = GuardianURLRequest.urlRequest(request: .removeDevice(encodedKey), type: .DELETE, httpHeaderParams: headers(with: token))

        networkLayer.fire(urlRequest: urlRequest) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(.success(()))
                case.failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func latestVersion(completion: @escaping (Result<Release, Error>) -> Void) {
        let urlRequest = GuardianURLRequest.urlRequest(request: .versions, type: .GET)
        networkLayer.fire(urlRequest: urlRequest) { result in
            completion(result.decode(to: Release.self))
        }
    }

    func downloadAvatar(_ url: URL, completion: @escaping (Result<Data?, GuardianAPIError>) -> Void) {
        let urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        networkLayer.fire(urlRequest: urlRequest, completion: completion)
    }

    // MARK: - Utils
    private func headers(with token: String) -> [String: String] {
        return ["Authorization": "Bearer \(token)",
            "Content-Type": "application/json",
            "User-Agent": userAgentInfo]
    }
}
