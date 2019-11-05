//
//  GuardianURLRequestBuilder
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import Foundation

struct GuardianURLRequestBuilder {
    private static let baseURL = "https://stage.guardian.nonprod.cloudops.mozgcp.net" // will have to change in future

    static func urlRequest(request: GuardianRelativeRequest,
                           type: HTTPMethod,
                           queryParameters: [String: String]? = nil,
                           httpHeaderParams: [String: String]? = nil,
                           body: Data? = nil) -> URLRequest {
        let urlString = "\(GuardianURLRequestBuilder.baseURL)\(request.endpoint)"

        return buildURLRequest(with: urlString, type: type, queryParameters: queryParameters, httpHeaderParams: httpHeaderParams, body: body)
    }

    static func urlRequest(fullUrlString: String,
                           type: HTTPMethod,
                           queryParameters: [String: String]? = nil,
                           httpHeaderParams: [String: String]? = nil,
                           body: Data? = nil) -> URLRequest {

        return buildURLRequest(with: fullUrlString, type: type, queryParameters: queryParameters, httpHeaderParams: httpHeaderParams, body: body)
    }

    private static func buildURLRequest(with urlString: String,
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
