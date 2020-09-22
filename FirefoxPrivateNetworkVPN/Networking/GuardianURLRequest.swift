//
//  GuardianURLRequestBuilder
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

struct GuardianURLRequest {
    private static var baseURL: String {
        #if STAGING
        return "https://stage-vpn.guardian.nonprod.cloudops.mozgcp.net/"
        #else
        return "https://vpn.mozilla.org/"
        #endif
    }

    static func urlRequest(request: GuardianURLRequestPath,
                           type: HttpMethod,
                           queryParameters: [String: String]? = nil,
                           httpHeaderParams: [String: String]? = nil,
                           body: Data? = nil) -> URLRequest {

        let urlString = "\(GuardianURLRequest.baseURL)\(request.endpoint)"

        return urlRequest(with: urlString, type: type, queryParameters: queryParameters, httpHeaderParams: httpHeaderParams, body: body)
    }

    static private func urlRequest(with urlString: String,
                                   type: HttpMethod,
                                   queryParameters: [String: String]? = nil,
                                   httpHeaderParams: [String: String]? = nil,
                                   body: Data? = nil) -> URLRequest {
        let url = generateURL(urlString: urlString, queryParameters: queryParameters)
        var urlRequest = URLRequest(url: url!)
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

    static private func generateURL(urlString: String, queryParameters: [String: String]?) -> URL? {
        var urlComponent = URLComponents(string: urlString)!
        if let queryParameters = queryParameters {
            let queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            urlComponent.queryItems = queryItems
        }

        return urlComponent.url
    }

    static func pkceLoginURL(codeChallenge: String) -> URL {
        let urlString = "\(GuardianURLRequest.baseURL)\(GuardianURLRequestPath.login.endpoint)"
        let queryParameters = ["code_challenge": codeChallenge, "code_challenge_method": "S256"]
        return generateURL(urlString: urlString, queryParameters: queryParameters)!
    }
}
