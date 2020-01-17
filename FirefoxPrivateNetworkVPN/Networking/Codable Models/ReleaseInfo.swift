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

    private let latestVersion: String
    private let minimumVersion: String
    let dateRetrieved: Date

    private var currentVersion: String {
        return UIApplication.appVersion ?? ""
    }

    var status: LatestReleaseStatus {
        if currentVersion >= latestVersion {
            return .none
        } else if compareCurrentToMinimum() == .orderedAscending {
            return .recommended
        } else {
            return .available
        }
    }

    init(with release: Release) {
        latestVersion = release.latestVersion
        minimumVersion = release.minimumVersion
        dateRetrieved = release.dateRetrieved
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        latestVersion = try container.decode(String.self, forKey: .latestVersion)
        minimumVersion = try container.decode(String.self, forKey: .minimumVersion)
        dateRetrieved = try container.decode(Date.self, forKey: .dateRetrieved)
    }

    private func compareCurrentToMinimum() -> ComparisonResult {
        let currentVersionArray = currentVersion.components(separatedBy: ".")
        let minimumVersionArray = minimumVersion.components(separatedBy: ".")
        let maxIndex = currentVersionArray.endIndex >= minimumVersionArray.endIndex ? currentVersionArray.endIndex : minimumVersionArray.endIndex

        for index in 0..<maxIndex {
            let currentVersionElement = currentVersionArray.indices.contains(index) ? currentVersionArray[index] : "0"
            let minimumVersionElement = minimumVersionArray.indices.contains(index) ? minimumVersionArray[index] : "0"
            let comparisonResult = currentVersionElement.compare(minimumVersionElement, options: .numeric)
            guard comparisonResult == .orderedSame else {
                return comparisonResult
            }
        }
        return .orderedSame
    }
}
