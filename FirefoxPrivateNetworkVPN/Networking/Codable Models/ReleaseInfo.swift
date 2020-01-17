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

struct ReleaseInfo: UserDefaulting {
    static var userDefaultsKey = "LatestRelease"

    let version: String
    let minimum: String
    let dateRetrieved: Date

    var status: LatestReleaseStatus {
        if version == UIApplication.appVersion {
            return .none
        } else if compareLatestToMinimum() == .orderedAscending {
            return .recommended
        } else {
            return .available
        }
    }

    private func compareLatestToMinimum() -> ComparisonResult {
        let latestVersionArray = version.components(separatedBy: ".")
        let minimumVersionArray = minimum.components(separatedBy: ".")
        let maxIndex = latestVersionArray.endIndex >= minimumVersionArray.endIndex ? latestVersionArray.endIndex : minimumVersionArray.endIndex

        for index in 0..<maxIndex {
            let latestVersionElement = latestVersionArray.indices.contains(index) ? latestVersionArray[index] : "0"
            let minimumVersionElement = minimumVersionArray.indices.contains(index) ? minimumVersionArray[index] : "0"
            let comparisonResult = latestVersionElement.compare(minimumVersionElement, options: .numeric)
            guard comparisonResult == .orderedSame else {
                return comparisonResult
            }
        }
        return .orderedSame
    }

    init(with release: Release) {
        version = release.latestVersion
        minimum = release.minimumVersion
        dateRetrieved = release.dateRetrieved
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        version = try container.decode(String.self, forKey: .version)
        minimum = try container.decode(String.self, forKey: .minimum)
        dateRetrieved = try container.decode(Date.self, forKey: .dateRetrieved)
    }
}
