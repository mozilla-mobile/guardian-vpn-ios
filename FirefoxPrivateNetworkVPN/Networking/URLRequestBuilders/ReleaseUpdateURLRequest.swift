//
//  ReleaseUpdateURLRequest
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Foundation

struct ReleaseUpdateURLRequest {
    private static let urlString = "https://aus5.mozilla.org/json/1/FirefoxVPN/0.2/iOS/ios-release/update.json"

    static func urlRequest() -> URLRequest {
        return URLRequestBuilder.urlRequest(with: ReleaseUpdateURLRequest.urlString, type: .GET)
    }
}
