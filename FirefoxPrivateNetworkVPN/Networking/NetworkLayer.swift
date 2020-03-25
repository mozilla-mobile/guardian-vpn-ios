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
            } else if let data = data,
                let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                completion(.failure(errorResponse.guardianAPIError))
            } else if let error = error as NSError?,
                error.code == errorCode(of: .cfurlErrorNotConnectedToInternet) {
                completion(.failure(.offline))
            } else {
                completion(.failure(.unknown))
            }
        }
        dataTask.resume()
    }
    
    fileprivate static func errorCode(of error: CFNetworkErrors) -> Int {
        return Int(error.rawValue)
    }
}

struct ErrorResponse: Codable {
    let code: Int
    let errno: Int
    let error: String

    var guardianAPIError: GuardianAPIError {
        return GuardianAPIError(rawValue: errno) ?? .unknown
    }
}
