//
//  Release
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Foundation

struct Release: Codable {
    let latestVersion: String
    let minimumVersion: String
    let dateRetrieved: Date
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let iosContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .ios)
        
        let latestContainer = try iosContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .latest)
        latestVersion = try latestContainer.decode(String.self, forKey: .version)
        
        let minimumContainer = try iosContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .minimum)
        minimumVersion = try minimumContainer.decode(String.self, forKey: .version)
        
        dateRetrieved = Date()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var iosContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .ios)
        var latestContainer = iosContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .latest)
        var minimumContainer = iosContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .minimum)
        
        try latestContainer.encode(latestVersion, forKey: .version)
        try minimumContainer.encode(minimumVersion, forKey: .minimum)
    }
    
    enum CodingKeys: String, CodingKey {
        case ios
        case latest
        case minimum
        case version
    }
}
