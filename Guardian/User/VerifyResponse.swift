// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Foundation

struct VerifyResponse: Codable {
    let user: User
    let token: String

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(user, forKey: .user)
        try container.encode(token, forKey: .token)
    }

    enum CodingKeys: String, CodingKey {
        case user
        case token
    }
}
