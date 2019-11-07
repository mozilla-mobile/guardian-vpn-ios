//
//  User
//  FirefoxPrivateNetworkVPN
//
//  Copyright © 2019 Mozilla Corporation. All rights reserved.
//

import Foundation

struct User: Codable {
    let email: String
    let displayName: String
    let avatarURL: URL?
    let vpnSubscription: Subscription
    let maxDevices: Int
    private var devices: [Device]
    private let avatarUrlString: String

    var deviceList: [Device] {
        get {
            return devices
        }
        set {
            devices = newValue.sorted { return $0.isCurrentDevice && !$1.isCurrentDevice }
        }
    }

    var canAddDevice: Bool {
        return devices.count < maxDevices
    }

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

        deviceList = devices
    }

    mutating func deviceIsBeingRemoved(with key: String) {
        for (index, each) in deviceList.enumerated() where each.publicKey == key {
            deviceList[index].isBeingRemoved = true
            return
        }
    }

    mutating func deviceFailedRemoval(with key: String) {
        for (index, each) in deviceList.enumerated() where each.publicKey == key {
            deviceList[index].isBeingRemoved = false
            return
        }
    }

    mutating func removeDevice(with key: String) {
        for (index, each) in deviceList.enumerated() where each.publicKey == key {
            deviceList.remove(at: index)
            return
        }
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
