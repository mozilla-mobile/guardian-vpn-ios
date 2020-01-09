//
//  URLRequestBuilder
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Foundation

struct URLRequestBuilder {
    static func urlRequest(with urlString: String,
                           type: HTTPMethod,
                           queryParameters: [String: String]? = nil,
                           httpHeaderParams: [String: String]? = nil,
                           body: Data? = nil) -> URLRequest {

        var urlComponent = URLComponents(string: urlString)!
        if let queryParameters = queryParameters {
            let queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            urlComponent.queryItems = queryItems
        }

        var urlRequest = URLRequest(url: urlComponent.url!)
        if let httpHeaderParams = httpHeaderParams {
            httpHeaderParams.forEach {
                urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
            }
        }

        urlRequest.httpMethod = type.rawValue

        if let body = body {
            urlRequest.httpBody = body
        }

        return urlRequest
    }
}
