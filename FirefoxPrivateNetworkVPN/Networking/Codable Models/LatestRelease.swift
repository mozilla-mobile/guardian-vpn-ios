//
//  LatestRelease
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import UIKit

struct LatestRelease: UserDefaulting {
    static var userDefaultsKey = "LatestRelease"

    let version: String
    let isRequired: Bool
    let dateRetrieved: Date

    var status: LatestReleaseStatus {
        if version == UIApplication.appVersion {
            return .none
        } else if isRequired {
            return .required
        } else {
            return .available
        }
    }

    init(with release: Release) {
        version = release.version
        isRequired = release.required
        dateRetrieved = release.dateRetrieved
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        version = try container.decode(String.self, forKey: .version)
        isRequired = try container.decode(Bool.self, forKey: .isRequired)
        dateRetrieved = try container.decode(Date.self, forKey: .dateRetrieved)
    }
}
