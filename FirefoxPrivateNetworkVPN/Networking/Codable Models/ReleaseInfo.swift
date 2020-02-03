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

    init(latestVersion: String, minimumVersion: String, dateRetrieved: Date) {
        self.latestVersion = latestVersion
        self.minimumVersion = minimumVersion
        self.dateRetrieved = dateRetrieved
    }

    init(with release: Release) {
        self.latestVersion = release.latestVersion
        self.minimumVersion = release.minimumVersion
        self.dateRetrieved = release.dateRetrieved
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        latestVersion = try container.decode(String.self, forKey: .latestVersion)
        minimumVersion = try container.decode(String.self, forKey: .minimumVersion)
        dateRetrieved = try container.decode(Date.self, forKey: .dateRetrieved)
    }

    func getUpdateStatus(of currentVersion: String = UIApplication.appVersion) -> UpdateStatus {

        switch (currentVersion.compare(with: latestVersion), currentVersion.compare(with: minimumVersion)) {
        case (_, .orderedAscending):
            return .required

        case (.orderedAscending, _):
            return .optional

        default:
            return .none
        }
    }
}

private extension String {
    func compare(with secondVersion: String) -> ComparisonResult {
        let firstArray = components(separatedBy: ".")
        let secondArray = secondVersion.components(separatedBy: ".")
        let maxIndex = secondArray.endIndex >= firstArray.endIndex ? secondArray.endIndex : firstArray.endIndex

        for index in 0..<maxIndex {
            let secondElement = secondArray.indices.contains(index) ? secondArray[index] : "0"
            let firstElement = firstArray.indices.contains(index) ? firstArray[index] : "0"
            let comparisonResult = firstElement.compare(secondElement, options: .numeric)
            guard comparisonResult == .orderedSame else {
                return comparisonResult
            }
        }
        return .orderedSame
    }
}
