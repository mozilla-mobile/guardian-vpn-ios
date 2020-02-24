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

import RxSwift
import RxCocoa

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

    mutating func deviceIsBeingRemoved(with key: String) {
        for (index, each) in devices.enumerated() where each.publicKey == key {
            devices[index].isBeingRemoved = true
            break
        }
    }

    mutating func deviceFailedRemoval(with key: String) {
        for (index, each) in devices.enumerated() where each.publicKey == key {
            devices[index].isBeingRemoved = false
            break
        }
    }

    mutating func removeDevice(with key: String) {
        for (index, each) in devices.enumerated() where each.publicKey == key {
            devices.remove(at: index)
            break
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

// MARK: -
struct Subscription: Codable {
    let isActive: Bool
    let createdAtDate: Date?
    let renewsOnDate: Date?

    private let createdAtDateString: String?
    private let renewsOnDateString: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        isActive = try container.decode(Bool.self, forKey: .active)

        let dateFormatter = GuardianAPIDateFormatter()
        if let dateString = try container.decodeIfPresent(String.self, forKey: .createdAt),
           let date = dateFormatter.date(from: dateString) {
            createdAtDateString = dateString
            createdAtDate = date
        } else {
            createdAtDateString = nil
            createdAtDate = nil
        }

        if let dateString = try container.decodeIfPresent(String.self, forKey: .renewsOn),
            let date = dateFormatter.date(from: dateString) {
            renewsOnDateString = dateString
            renewsOnDate = date
        } else {
            renewsOnDateString = nil
            renewsOnDate = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(isActive, forKey: .active)
        try container.encodeIfPresent(createdAtDateString, forKey: .createdAt)
        try container.encodeIfPresent(renewsOnDateString, forKey: .renewsOn)
    }

    enum CodingKeys: String, CodingKey {
        case active
        case createdAt = "created_at"
        case renewsOn = "renews_on"
    }
}
