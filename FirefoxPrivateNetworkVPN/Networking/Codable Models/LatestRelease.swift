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
    let minimum: String
    let dateRetrieved: Date
    
    lazy var status: LatestReleaseStatus = {
        if version == UIApplication.appVersion {
            return .none
        } else if isUpdateRequired {
            return .required
        } else {
            return .available
        }
    }()
    
    lazy var isUpdateRequired: Bool = {
        let first = version.components(separatedBy: ".")
        let second = minimum.components(separatedBy: ".")
        let maxIndex = first >= second.endIndex ? first.endIndex : second.endIndex
        
        for index in 0..<maxIndex {
            let firstElement = first.indices.contains(index) ? first[index] : "0"
            let secondElement = second.indices.contains(index) ? second[index] : "0"
            let comparisonResult = firstElement.compare(secondElement, options: .numeric)
            guard comparisonResult == .orderedSame else {
                return comparisonResult == .orderedAscending
            }
        }
        return false
    }()
    
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
