//
//  GuardianAPI
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import Foundation

class GuardianAPI: NetworkRequesting {

    static func initiateUserLogin(completion: @escaping (Result<LoginCheckpointModel, Error>) -> Void) {
        let urlRequest = GuardianURLRequestBuilder.urlRequest(request: .login, type: .POST)
        NetworkLayer.fireURLRequest(with: urlRequest) { result in
            completion(result.flatMap { $0.convert(to: LoginCheckpointModel.self) })
        }
    }

    static func accountInfo(token: String, completion: @escaping (Result<User, Error>) -> Void) {
        let urlRequest = GuardianURLRequestBuilder.urlRequest(request: .account, type: .GET, httpHeaderParams: headers(with: token))
        NetworkLayer.fireURLRequest(with: urlRequest) { result in
            completion(result.flatMap { $0.convert(to: User.self) })
        }
    }

    static func verify(urlString: String, completion: @escaping (Result<VerifyResponse, Error>) -> Void) {
        let urlRequest = GuardianURLRequestBuilder.urlRequest(fullUrlString: urlString, type: .GET)
        NetworkLayer.fireURLRequest(with: urlRequest) { result in
            completion(result.flatMap { $0.convert(to: VerifyResponse.self) })
        }
    }

    static func availableServers(with token: String, completion: @escaping (Result<[VPNCountry], Error>) -> Void) {
        let urlRequest = GuardianURLRequestBuilder.urlRequest(request: .retrieveServers, type: .GET, httpHeaderParams: headers(with: token))
        NetworkLayer.fireURLRequest(with: urlRequest) { result in
            completion(result
                .flatMap { $0.convert(to: [String: [VPNCountry]].self) }
                .map { $0["countries"]! })
        }
    }

    static func addDevice(with token: String, body: [String: Any], completion: @escaping (Result<Device, GuardianAPIError>) -> Void) {
        guard let data = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(.couldNotCreateBody))
            return
        }

        let urlRequest = GuardianURLRequestBuilder.urlRequest(request: .addDevice, type: .POST, httpHeaderParams: headers(with: token), body: data)
        NetworkLayer.fire(urlRequest: urlRequest, dataHandler: { result in
            switch result {
            case .success(let data):
                if let device = try? data.convert(to: Device.self).get() {
                    completion(.success(device))
                    return
                }
            case .failure(let error):
                print(error)
                completion(.failure(error))
//            completion(result.flatMap { try $0.convert(to: Device.self) })
            }
        })
    }

    static func removeDevice(with token: String, deviceKey: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let encodedKey = deviceKey.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion(Result { throw GuardianFailReason.emptyToken })
            return
        }

        let urlRequest = GuardianURLRequestBuilder.urlRequest(request: .removeDevice(encodedKey), type: .DELETE, httpHeaderParams: headers(with: token))

        NetworkLayer.fire(urlRequest: urlRequest, errorHandler: completion)
    }

    private static func headers(with token: String) -> [String: String] {
        return ["Authorization": "Bearer \(token)",
                "Content-Type": "application/json"]
    }
}

enum GuardianAPIError: Error {
    case addDeviceFailure(Data)
    case couldNotCreateBody
    case other(Error)
    case errorWithData(Error, Data?)
}
