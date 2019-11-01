// SPDX-License-Identifier: MPL-2.0
// Copyright © 2019 Mozilla Corporation. All Rights Reserved.

import Foundation

struct Device: Codable, UserDefaulting {
    let name: String
    let publicKey: String
    let ipv4Address: String
    let ipv6Address: String
    let createdAtDate: Date
    static var userDefaultsKey = "currentDevice"

    private let createdAtDateString: String

    var isCurrentDevice: Bool {
        return publicKey == Device.fetchFromUserDefaults()?.publicKey
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
