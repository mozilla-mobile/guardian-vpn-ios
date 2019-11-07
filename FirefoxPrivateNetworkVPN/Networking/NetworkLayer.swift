//
//  NetworkLayer
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
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
                response.statusCode == 200 || response.statusCode == 201 {
                completion(.success(data))
            } else {
                completion(.failure(GuardianFailReason.no200))
            }
        }
        dataTask.resume()
    }

    static func fire(urlRequest: URLRequest, completion: @escaping (Result<Data, GuardianAPIError>) -> Void) {
        let defaultSession = URLSession(configuration: .default)
        defaultSession.configuration.timeoutIntervalForRequest = 120

        let dataTask = defaultSession.dataTask(with: urlRequest) { data, response, error in
            if let error = error, let data = data {
                completion(.failure(GuardianAPIError.errorWithData(error, data)))
            } else if let data = data, let response = response as? HTTPURLResponse,
                response.statusCode == 200 || response.statusCode == 201 {
                completion(.success(data))
            } else if let error = error {
                completion(.failure(.other(error)))
            } else {
                completion(.failure(.other(GuardianFailReason.no200)))
            }
        }
        dataTask.resume()
    }

    static func fire(urlRequest: URLRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        let defaultSession = URLSession(configuration: .default)
        defaultSession.configuration.timeoutIntervalForRequest = 120

        let dataTask = defaultSession.dataTask(with: urlRequest) { _, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let response = response as? HTTPURLResponse,
                response.statusCode == 200 || response.statusCode == 201 {
                completion(.success(()))
            } else {
                completion(.failure(GuardianFailReason.no200))
            }
        }
        dataTask.resume()
    }
}

extension Data: Error { }
