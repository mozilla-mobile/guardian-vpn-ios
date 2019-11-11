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
    static func fireURLRequest(with urlRequest: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        let defaultSession = URLSession(configuration: .default)
        defaultSession.configuration.timeoutIntervalForRequest = 120

        let dataTask = defaultSession.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                completion(.success(data))
            } else {
                completion(.failure(GuardianFailReason.no200))
            }
        }
        dataTask.resume()
    }

    static func fire(urlRequest: URLRequest, dataHandler: @escaping (Result<Data, GuardianAPIError>) -> Void) {
        let defaultSession = URLSession(configuration: .default)
        defaultSession.configuration.timeoutIntervalForRequest = 120

        let dataTask = defaultSession.dataTask(with: urlRequest) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse,
            response.statusCode == 201 {
                dataHandler(.success(data))
            } else {
                dataHandler(.failure(GuardianAPIError.addDeviceFailure(data)))
            }
        }
        dataTask.resume()
    }

    static func fire(urlRequest: URLRequest, errorHandler: @escaping (Result<Void, Error>) -> Void) {
        let defaultSession = URLSession(configuration: .default)
        defaultSession.configuration.timeoutIntervalForRequest = 120

        let dataTask = defaultSession.dataTask(with: urlRequest) { _, response, error in
            if let error = error {
                errorHandler(.failure(error))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 204 {
                errorHandler(.success(()))
            } else {
                errorHandler(.failure(GuardianFailReason.no200))
            }
        }
        dataTask.resume()
    }
}

extension Data: Error { }
