//
//  NetworkLayer
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

class NetworkLayer {

    static func fire(urlRequest: URLRequest, completion: @escaping (Result<Data?, GuardianAPIError>) -> Void) {
        let defaultSession = URLSession(configuration: .default)
        defaultSession.configuration.timeoutIntervalForRequest = 120

        let dataTask = defaultSession.dataTask(with: urlRequest) { data, response, error in
            if let response = response as? HTTPURLResponse, 200...210 ~= response.statusCode {
                completion(.success(data))
            } else if error != nil, let data = data {
                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data)
                completion(.failure(errorResponse?.guardianError ?? .unknownClient))
            } else {
                completion(.failure(.unknownServer))
            }
        }
        dataTask.resume()
    }
}

enum GuardianAPIError: Int, Error {
    // Add Device
    case missingPubKey = 100
    case missingName = 101
    case invalidPubKey = 102
    case pubKeyAlreadyInUse = 103
    case maxDevicesReached = 104
    // Remove Device
    case pubKeyNotFound = 105
    // Authorization
    case tokenInvalid = 120
    case userNotFound = 121
    case deviceNotFound = 122
    case inactiveSubscription = 123
    // Authentication
    case tokenNotFound = 124
    case tokenExpired = 125
    case tokenNotVerified = 126

    case unknownClient = 400
    case unknownServer = 500

    var description: String {
        switch self {
        case .missingPubKey:
            return "Missing key argument"
        case .missingName:
            return "Missing name argument"
        case .invalidPubKey:
            return "Not a valid WireGuard key"
        case .pubKeyAlreadyInUse:
            return "WireGuard key already used by other account"
        case .maxDevicesReached:
            return "The account has already reached the maximum allowed devices"
        case .pubKeyNotFound:
            return "A device with that key does not exist"
        case .tokenInvalid:
            return "Invalid token"
        case .userNotFound:
            return "User not found"
        case .deviceNotFound:
            return "Device not found"
        case .inactiveSubscription:
            return "User doesn’t have an active subscription"
        case .tokenNotFound:
            return "Login token not found"
        case .tokenExpired:
            return "Login token expired"
        case .tokenNotVerified:
            return "Login token isn't verified"

        default:
            return "Unknown error"
        }
    }
}

struct ErrorResponse: Codable {
    let code: Int
    let errorno: Int
    let error: String

    var guardianError: GuardianAPIError {
        return GuardianAPIError(rawValue: errorno) ?? .unknownServer
    }
}
