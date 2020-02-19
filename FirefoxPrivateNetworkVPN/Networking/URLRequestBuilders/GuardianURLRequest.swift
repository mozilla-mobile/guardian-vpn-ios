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
    private static let productionBaseURL = "https://fpn.firefox.com/"
    private static let stagingBaseURL = "https://stage.guardian.nonprod.cloudops.mozgcp.net/"

    private static var baseURL: String {
        #if DEBUG
        return GuardianURLRequest.stagingBaseURL
        #else
        return GuardianURLRequest.productionBaseURL
        #endif
    }

    static func urlRequest(request: GuardianRelativeRequest,
                           type: HTTPMethod,
                           queryParameters: [String: String]? = nil,
                           httpHeaderParams: [String: String]? = nil,
                           body: Data? = nil) -> URLRequest {

        let urlString = "\(GuardianURLRequest.baseURL)\(request.endpoint)"

        return URLRequestBuilder.urlRequest(with: urlString, type: type, queryParameters: queryParameters, httpHeaderParams: httpHeaderParams, body: body)
    }
}
