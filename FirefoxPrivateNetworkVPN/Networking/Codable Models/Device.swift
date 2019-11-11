//
//  Device
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

struct Device: Codable, UserDefaulting {

    static let userDefaultsKey = "currentDevice"
    let name: String
    let publicKey: String
    let ipv4Address: String
    let ipv6Address: String
    let createdAtDate: Date
    private let createdAtDateString: String
    var isBeingRemoved: Bool = false

    var isCurrentDevice: Bool {
        return self == Device.fetchFromUserDefaults()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        publicKey = try container.decode(String.self, forKey: .pubkey)
        ipv4Address = try container.decode(String.self, forKey: .ipv4Address)
        ipv6Address = try container.decode(String.self, forKey: .ipv6Address)

        createdAtDateString = try container.decode(String.self, forKey: .createAtDate)
        let dateFormatter = GuardianAPIDateFormatter()
        createdAtDate = dateFormatter.date(from: createdAtDateString)!
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(publicKey, forKey: .pubkey)
        try container.encode(ipv4Address, forKey: .ipv4Address)
        try container.encode(ipv6Address, forKey: .ipv6Address)
        try container.encode(createdAtDateString, forKey: .createAtDate)
    }

    enum CodingKeys: String, CodingKey {
        case name
        case pubkey
        case ipv4Address = "ipv4_address"
        case ipv6Address = "ipv6_address"
        case createAtDate = "created_at"
    }
}

extension Device: Equatable {
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.publicKey == rhs.publicKey
    }
}
