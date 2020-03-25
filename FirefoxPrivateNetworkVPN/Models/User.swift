//
//  User
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2019 Mozilla Corporation.
//

import Foundation

struct User: Codable {
    let email: String
    let displayName: String
    let avatarURL: URL?
    let vpnSubscription: Subscription
    let maxDevices: Int

    private(set) var devices: [Device]
    private let avatarUrlString: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        email = try container.decode(String.self, forKey: .email)
        displayName = try container.decode(String.self, forKey: .displayName)
        devices = try container.decode([Device].self, forKey: .devices)
        maxDevices = try container.decode(Int.self, forKey: .maxDevices)

        avatarUrlString = try container.decode(String.self, forKey: .avatar)
        avatarURL = URL(string: avatarUrlString)

        let subscriptionsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .subscriptions)
        vpnSubscription = try subscriptionsContainer.decode(Subscription.self, forKey: .vpn)
    }

    mutating func markIsBeingRemoved(for device: Device) {
        if let index = devices.firstIndex(where: { $0 == device }) {
            devices[index].isBeingRemoved = true
        }
    }

    mutating func failedRemoval(of device: Device) {
        if let index = devices.firstIndex(where: { $0 == device }) {
            devices[index].isBeingRemoved = false
        }
    }

    mutating func remove(device: Device) {
        if let index = devices.firstIndex(where: { $0 == device }) {
            devices.remove(at: index)
        }
    }

    func has(device: Device) -> Bool {
        return devices.contains(device)
    }

    func device(with key: String) -> Device? {
        return devices.filter { $0.publicKey == key }.first
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(email, forKey: .email)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(avatarUrlString, forKey: .avatar)
        try container.encode(devices, forKey: .devices)
        try container.encode(maxDevices, forKey: .maxDevices)

        var subscriptionsContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .subscriptions)
        try subscriptionsContainer.encode(vpnSubscription, forKey: .vpn)
    }

    enum CodingKeys: String, CodingKey {
        case email
        case displayName = "display_name"
        case avatar
        case subscriptions
        case vpn
        case devices
        case maxDevices = "max_devices"
    }
}
