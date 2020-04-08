//
//  Subscription
//  FirefoxPrivateNetworkVPN
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
//  Copyright © 2020 Mozilla Corporation.
//

import Foundation

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
