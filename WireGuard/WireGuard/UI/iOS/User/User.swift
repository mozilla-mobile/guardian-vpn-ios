// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

struct User: Codable {
    let email: String
    let displayName: String
    let avatarUrlString: String
    let vpnSubscription: Subscription
    let devices: [Device]
    let maxDevices: Int
    static var userDefaultsKey = "currentUserUserDefaults"

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        email = try container.decode(String.self, forKey: .email)
        displayName = try container.decode(String.self, forKey: .displayName)
        avatarUrlString = try container.decode(String.self, forKey: .avatar)
        devices = try container.decode([Device].self, forKey: .devices)
        maxDevices = try container.decode(Int.self, forKey: .maxDevices)

        let subscriptionsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .subscriptions)
        vpnSubscription = try subscriptionsContainer.decode(Subscription.self, forKey: .vpn)
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

struct Subscription: Codable {
    let isActive: Bool
    let createdAtDate: Date?
    let renewsOnDate: Date?

    let createdAtDateString: String?
    let renewsOnDateString: String?

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
